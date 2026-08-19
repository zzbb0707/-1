extends Node2D

const VIEW_SIZE := Vector2(1000, 1250)
const AppBridgeScript = preload("res://scripts/app_bridge.gd")
const DEFAULT_CONFIG := "res://configs/game004_l1_slice.json"
const ASSET_ROOT := "res://assets/processed/v001/"
const STAGE := Rect2(170, 175, 660, 950)
const DEFAULT_OBJECT_RECT := Rect2(365, 810, 270, 170)

var launch_context: Dictionary = {
    "schema_version": "game-bridge-v0", "task_id": "GAME-004",
    "game_config_id": "GAMECFG-GAME-004-SLICE-L1", "task_session_id": "preview-session",
    "child_profile_id": "preview-child", "daily_plan_id": "preview-plan", "debug": true,
    "low_sensory": false, "launch_mode": "preview", "content_version": "GAME-004-V2",
    "ruleset_version": "GAME004-SLICE-V1"
}
var bridge = AppBridgeScript.new()
var game_config: Dictionary = {}
var events: Array[Dictionary] = []
var rounds: Array = []
var regions: Dictionary = {}
var background: Texture2D
var current_object_texture: Texture2D
var object_rect := DEFAULT_OBJECT_RECT
var config_path := DEFAULT_CONFIG
var slice_id := "L1"
var round_index := 0
var current_round_started_ms := 0
var session_started_ms := 0
var first_response_ms := -1
var attempt_count := 0
var error_count := 0
var hint_count := 0
var completed_count := 0
var selected_object := false
var selected_region := ""
var drag_object := false
var drag_position := Vector2.ZERO
var pointer_down_position := Vector2.ZERO
var pointer_dragged := false
var message := "观察环境，把对象放到合适的区域"
var message_tone := Color("#dbeafe")
var feedback_until_ms := 0
var feedback_region := ""
var debug_open := true
var session_status := "started"

func _ready() -> void:
    _resolve_config_path()
    _load_game_config()
    _load_launch_context()
    session_started_ms = Time.get_ticks_msec()
    _emit("game_start", {"slice_id": slice_id, "round_count": rounds.size(), "region_count": regions.size(), "launch_mode": launch_context.get("launch_mode", "preview"), "low_sensory": launch_context.get("low_sensory", false)})
    _start_round(0)
    queue_redraw()

func _resolve_config_path() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--slice="):
            var requested := arg.trim_prefix("--slice=").to_upper()
            if requested in ["L1", "L3", "L4"]:
                config_path = "res://configs/game004_%s_slice.json" % requested.to_lower()

func _load_game_config() -> void:
    var file := FileAccess.open(config_path, FileAccess.READ)
    if not file:
        push_error("GAME-004 config missing: " + config_path)
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        push_error("GAME-004 invalid config: " + config_path)
        return
    game_config = parsed
    slice_id = str(game_config.get("slice_id", "L1"))
    launch_context.game_config_id = str(game_config.get("game_config_id", launch_context.game_config_id))
    message = str(game_config.get("child_prompt", message))
    rounds = game_config.get("rounds", [])
    var object_position: Array = game_config.get("object_position", [0.5, 0.68])
    object_rect = Rect2(STAGE.position + Vector2(float(object_position[0]) * STAGE.size.x - 135.0, float(object_position[1]) * STAGE.size.y - 85.0), Vector2(270, 170))
    regions.clear()
    for raw_region in game_config.get("regions", []):
        var normalized: Array = raw_region.get("rect", [0.1, 0.4, 0.3, 0.3])
        var rect := Rect2(STAGE.position + Vector2(float(normalized[0]) * STAGE.size.x, float(normalized[1]) * STAGE.size.y), Vector2(float(normalized[2]) * STAGE.size.x, float(normalized[3]) * STAGE.size.y))
        regions[str(raw_region.name)] = {"rect": rect, "kind": raw_region.get("kind", "unknown"), "color": Color(str(raw_region.get("color", "#4f7f78")))}
    var image_path := str(game_config.get("background", ""))
    if ResourceLoader.exists(image_path): background = load(image_path)
    current_object_texture = null
    _load_object_texture()

func _load_object_texture() -> void:
    if rounds.is_empty() or round_index >= rounds.size(): return
    var object_name := str(rounds[round_index].get("object", ""))
    var asset_path := ""
    if object_name.contains("水") or object_name.contains("浮叶"):
        asset_path = ASSET_ROOT + "GAME004_asset_object_water_seed_v001.png"
    elif object_name.contains("苔") or object_name.contains("林"):
        asset_path = ASSET_ROOT + "GAME004_asset_object_moss_bud_v001.png"
    elif object_name.contains("铲") or object_name.contains("工具"):
        asset_path = ASSET_ROOT + "GAME004_asset_object_tool_v001.png"
    elif object_name.contains("向阳") or object_name.contains("花"):
        asset_path = ASSET_ROOT + "GAME004_asset_object_sun_seed_v001.png"
    if asset_path != "" and ResourceLoader.exists(asset_path): current_object_texture = load(asset_path)

func _load_launch_context() -> void:
    launch_context = bridge.load_context(launch_context)
    debug_open = bool(launch_context.get("debug", false)) or OS.is_debug_build()

func _start_round(index: int) -> void:
    round_index = index
    selected_object = false
    selected_region = ""
    drag_object = false
    first_response_ms = -1
    current_round_started_ms = Time.get_ticks_msec()
    _load_object_texture()
    message = str(game_config.get("child_prompt", "观察环境，把对象放到合适的区域"))
    message_tone = Color("#dbeafe")
    var data: Dictionary = rounds[round_index]
    _emit("opportunity_presented", {"opportunity_id": data.get("opportunity_id", "GAME004-R%02d" % (round_index + 1)), "slice_id": slice_id, "object": data.get("object", "对象"), "regions": regions.keys(), "rule_id": data.get("rule_id", game_config.get("rule_id", "habitat")), "examples": data.get("examples", [])})
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            _request_quit("user_escape")
        elif event.keycode == KEY_1:
            _switch_slice("L1")
        elif event.keycode == KEY_3:
            _switch_slice("L3")
        elif event.keycode == KEY_4:
            _switch_slice("L4")
        return
    if session_status != "started": return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed: _pointer_down(event.position)
        else: _pointer_up(event.position)
    elif event is InputEventMouseMotion and drag_object:
        if event.position.distance_to(pointer_down_position) > 12.0: pointer_dragged = true
        drag_position = event.position
        queue_redraw()

func _switch_slice(level: String) -> void:
    config_path = "res://configs/game004_%s_slice.json" % level.to_lower()
    session_status = "started"
    round_index = 0; attempt_count = 0; error_count = 0; hint_count = 0; completed_count = 0
    _load_game_config()
    _emit("slice_preview_changed", {"slice_id": slice_id})
    _start_round(0)

func _pointer_down(position: Vector2) -> void:
    if Rect2(850, 40, 100, 58).has_point(position): _request_quit("toolbar_quit"); return
    if Rect2(720, 40, 110, 58).has_point(position): _show_hint(); return
    pointer_down_position = position; pointer_dragged = false
    if object_rect.has_point(position):
        if first_response_ms < 0:
            first_response_ms = Time.get_ticks_msec()
            _emit("first_response", {"reaction_time_ms": first_response_ms - current_round_started_ms, "input_method": "tap"})
        drag_object = true; drag_position = position; queue_redraw(); return
    for region_name in regions:
        if regions[region_name].rect.has_point(position) and selected_object:
            _attempt_region(region_name, "tap"); return

func _pointer_up(position: Vector2) -> void:
    if not drag_object: return
    drag_object = false
    if not pointer_dragged:
        selected_object = true; message = "现在选择一个区域"; queue_redraw(); return
    for region_name in regions:
        if regions[region_name].rect.has_point(position): _attempt_region(region_name, "drag"); return
    message = "再试一次，把它放进一个区域"; message_tone = Color("#f9d6a5"); queue_redraw()

func _attempt_region(region_name: String, input_method: String) -> void:
    var data: Dictionary = rounds[round_index]
    attempt_count += 1
    var is_correct := region_name == str(data.get("correct_region", ""))
    var opportunity_id := str(data.get("opportunity_id", "GAME004-R%02d" % (round_index + 1)))
    _emit("attempt", {"opportunity_id": opportunity_id, "slice_id": slice_id, "object": data.get("object", "对象"), "selected_region": region_name, "rule_id": data.get("rule_id", "habitat"), "input_method": input_method, "correct": is_correct})
    if is_correct:
        completed_count += 1; selected_region = region_name; feedback_region = region_name
        message = str(data.get("success_message", "这里适合它，生态开始运转了")); message_tone = Color("#b9f6c4")
        feedback_until_ms = Time.get_ticks_msec() + 900
        _emit("success", {"opportunity_id": opportunity_id, "slice_id": slice_id, "prompt_level": 0, "first_attempt": attempt_count == completed_count})
        queue_redraw(); await get_tree().create_timer(0.95).timeout
        if session_status != "started": return
        if round_index + 1 >= rounds.size(): _complete_game()
        else: _start_round(round_index + 1)
    else:
        error_count += 1; message = "还差一点，我们再看看当前规则"; message_tone = Color("#f9d6a5")
        _emit("error", {"opportunity_id": opportunity_id, "slice_id": slice_id, "error_type": "wrong_region", "selected_region": region_name})
        await get_tree().create_timer(0.35).timeout
        if session_status == "started": _show_hint()

func _show_hint() -> void:
    hint_count += 1
    var data: Dictionary = rounds[round_index]
    message = str(data.get("hint", "看看区域的样子，再试一次")); message_tone = Color("#ffe7a3")
    _emit("hint_shown", {"opportunity_id": data.get("opportunity_id", ""), "slice_id": slice_id, "hint_level": 1, "reason": "user_or_repair"})
    queue_redraw()

func _complete_game() -> void:
    session_status = "completed"; message = "%s代表关完成" % slice_id; message_tone = Color("#b9f6c4")
    var summary := _result_payload()
    _emit("game_complete", summary); _emit("game_result", bridge.build_result(session_status, summary)); queue_redraw()

func _request_quit(reason: String) -> void:
    if session_status != "started": return
    session_status = "quit"
    _emit("game_quit", {"reason": reason, "slice_id": slice_id, "completed_count": completed_count, "round_index": round_index + 1})
    _emit("game_result", bridge.build_result(session_status, _result_payload()))
    message = "已安全退出"; queue_redraw()

func _result_payload() -> Dictionary:
    return {"session_status": session_status, "slice_id": slice_id, "difficulty_level": game_config.get("difficulty_level", slice_id), "completed_count": completed_count, "attempt_count": attempt_count, "error_count": error_count, "hint_count": hint_count, "auto_success_rate": float(completed_count) / max(1.0, float(attempt_count)), "quit_before_finish": session_status != "completed", "stop_used": false, "downgrade_used": false, "safety_event": false, "duration_sec": (Time.get_ticks_msec() - session_started_ms) / 1000.0}

func _emit(event_type: String, payload: Dictionary) -> void:
    events.append(bridge.emit_event(event_type, payload))

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color("#10243a"))
    draw_string(ThemeDB.fallback_font, Vector2(55, 82), "星图生态舱｜%s代表关" % slice_id, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color("#f5fbff"))
    draw_string(ThemeDB.fallback_font, Vector2(55, 125), "按 1 / 3 / 4 切换难度纵切" , HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#a9c5dd"))
    draw_string(ThemeDB.fallback_font, Vector2(55, 155), "回合 %d / %d" % [mini(round_index + 1, rounds.size()), rounds.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#c7dded"))
    _draw_button(Rect2(720, 40, 110, 58), "提示", Color("#286a86")); _draw_button(Rect2(850, 40, 100, 58), "退出", Color("#66566f"))
    if background: draw_texture_rect(background, STAGE, false)
    else: draw_rect(STAGE, Color("#17324b"), true)
    draw_rect(STAGE, Color("#d9e8df"), false, 3)
    for region_name in regions: _draw_region(region_name, regions[region_name])
    if feedback_region != "" and Time.get_ticks_msec() < feedback_until_ms:
        _draw_feedback(feedback_region)
    var data: Dictionary = rounds[round_index]
    var object_pos := drag_position if drag_object else object_rect.get_center()
    if selected_region != "": object_pos = regions[selected_region].rect.get_center()
    _draw_object(object_pos, str(data.get("object", "对象")), Color(str(data.get("object_color", "#8ed0b2"))))
    _draw_rule(data)
    draw_rect(Rect2(190, 1050, 620, 58), Color(0.05, 0.12, 0.18, 0.88), true)
    draw_string(ThemeDB.fallback_font, Vector2(215, 1088), message, HORIZONTAL_ALIGNMENT_CENTER, 570, 25, message_tone)
    if session_status != "started":
        draw_rect(Rect2(245, 520, 510, 180), Color(0.04, 0.12, 0.2, 0.94), true)
        draw_string(ThemeDB.fallback_font, Vector2(285, 610), message, HORIZONTAL_ALIGNMENT_CENTER, 430, 34, message_tone)
    if debug_open: draw_string(ThemeDB.fallback_font, Vector2(55, 1205), "DEBUG %s events=%d attempts=%d errors=%d hints=%d" % [session_status, events.size(), attempt_count, error_count, hint_count], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#7fa2bd"))

func _draw_feedback(region_name: String) -> void:
    var region: Dictionary = regions.get(region_name, {})
    if region.is_empty(): return
    var rect: Rect2 = region.rect
    var tone := Color("#b8f4d3")
    draw_arc(rect.get_center(), min(rect.size.x, rect.size.y) * 0.36, 0, TAU, 32, tone, 6)
    draw_circle(rect.get_center(), 12, tone)
    if not bool(launch_context.get("low_sensory", false)):
        draw_circle(rect.get_center() + Vector2(0, -30), 7, Color("#fff1a8"))
        draw_circle(rect.get_center() + Vector2(25, -10), 5, Color("#fff1a8"))
    draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, 32), "生态启动", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 20, tone)

func _draw_rule(data: Dictionary) -> void:
    var label := str(data.get("rule_label", game_config.get("rule_label", "按生态需要安排")))
    draw_style_box(_box(Color(0.92, 0.88, 0.76, 0.92), 16, Color("#6f978e")), Rect2(285, 205, 430, 54))
    draw_string(ThemeDB.fallback_font, Vector2(305, 241), label, HORIZONTAL_ALIGNMENT_CENTER, 390, 24, Color("#24433f"))
    var examples: Array = data.get("examples", [])
    if not examples.is_empty():
        draw_string(ThemeDB.fallback_font, Vector2(310, 282), "范例：" + "　".join(examples), HORIZONTAL_ALIGNMENT_CENTER, 380, 19, Color("#f7f2dc"))

func _draw_region(name: String, data: Dictionary) -> void:
    var rect: Rect2 = data.rect
    var fill: Color = data.color
    fill.a = 0.16 if bool(launch_context.get("low_sensory", false)) else 0.24
    draw_style_box(_box(fill, 22, Color(0.95, 1.0, 0.92, 0.85)), rect)
    draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y - 16), name, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, Color("#ffffff"))

func _draw_object(pos: Vector2, label: String, color: Color) -> void:
    if current_object_texture:
        var target := Rect2(pos - Vector2(62, 62), Vector2(124, 124))
        draw_texture_rect(current_object_texture, target, false)
    else:
        draw_circle(pos, 61, Color(0.03, 0.08, 0.12, 0.6)); draw_circle(pos, 53, color); draw_circle(pos - Vector2(16, 16), 14, Color(1, 1, 1, 0.55))
    draw_string(ThemeDB.fallback_font, pos + Vector2(-115, 88), label, HORIZONTAL_ALIGNMENT_CENTER, 230, 27, Color("#ffffff"))

func _draw_button(rect: Rect2, label: String, color: Color) -> void:
    draw_style_box(_box(color, 12, color.lightened(0.18)), rect)
    draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, 37), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 24, Color("#f4fbff"))

func _box(fill: Color, radius: int, border: Color) -> StyleBoxFlat:
    var box := StyleBoxFlat.new(); box.bg_color = fill
    box.corner_radius_top_left = radius; box.corner_radius_top_right = radius; box.corner_radius_bottom_left = radius; box.corner_radius_bottom_right = radius
    box.border_width_left = 2; box.border_width_right = 2; box.border_width_top = 2; box.border_width_bottom = 2; box.border_color = border
    return box
