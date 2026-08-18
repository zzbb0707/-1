extends Node2D

const VIEW_SIZE := Vector2(1000, 1250)
const AppBridgeScript = preload("res://scripts/app_bridge.gd")
const STAGE := Rect2(55, 195, 890, 900)
const ROUND_COUNT := 3

var launch_context: Dictionary = {
    "schema_version": "game-bridge-v0",
    "task_id": "GAME-004",
    "game_config_id": "GAMECFG-GAME-004-GF03-L1-P01",
    "task_session_id": "preview-session",
    "child_profile_id": "preview-child",
    "daily_plan_id": "preview-plan",
    "debug": true,
    "low_sensory": false,
    "launch_mode": "preview",
    "content_version": "GAME-004-V1",
    "ruleset_version": "ALLOC-CORE-V1"
}

var bridge = AppBridgeScript.new()
var events: Array[Dictionary] = []
var round_index := 0
var current_round_started_ms := 0
var first_response_ms := -1
var attempt_count := 0
var error_count := 0
var hint_count := 0
var completed_count := 0
var selected_object := ""
var selected_region := ""
var drag_object := ""
var drag_position := Vector2.ZERO
var pointer_down_position := Vector2.ZERO
var pointer_dragged := false
var message := "把发光物放到合适的区域"
var message_tone := Color("#dbeafe")
var feedback_until_ms := 0
var debug_open := true
var session_status := "started"

var rounds := [
    {"object": "水生种子", "kind": "water", "correct": "水池", "wrong": "阳光花圃", "object_color": Color("#77d8e8")},
    {"object": "向阳种子", "kind": "sun", "correct": "阳光花圃", "wrong": "水池", "object_color": Color("#ffd46a")},
    {"object": "晶体幼苗", "kind": "water", "correct": "水池", "wrong": "阳光花圃", "object_color": Color("#b8a6ff")}
]

var regions := {
    "水池": {"rect": Rect2(100, 600, 360, 360), "color": Color("#3b9bb1"), "accent": Color("#8ff5ff"), "kind": "water"},
    "阳光花圃": {"rect": Rect2(540, 600, 360, 360), "color": Color("#b9853f"), "accent": Color("#ffe28a"), "kind": "sun"}
}

func _ready() -> void:
    _load_launch_context()
    _emit("game_start", {"round_count": ROUND_COUNT, "launch_mode": launch_context.get("launch_mode", "preview")})
    _start_round(0)
    queue_redraw()

func _load_launch_context() -> void:
    launch_context = bridge.load_context(launch_context)
    debug_open = bool(launch_context.get("debug", false)) or OS.is_debug_build()

func _start_round(index: int) -> void:
    round_index = index
    selected_object = ""
    selected_region = ""
    drag_object = ""
    first_response_ms = -1
    current_round_started_ms = Time.get_ticks_msec()
    message = "把发光物放到合适的区域"
    message_tone = Color("#dbeafe")
    var data: Dictionary = rounds[round_index]
    _emit("opportunity_presented", {"opportunity_id": "GAME004-R%02d" % (round_index + 1), "object": data.object, "regions": ["水池", "阳光花圃"], "rule": "按生态需要安排"})
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        _request_quit("user_escape")
        return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            _pointer_down(event.position)
        else:
            _pointer_up(event.position)
    elif event is InputEventMouseMotion and drag_object != "":
        if event.position.distance_to(pointer_down_position) > 12.0:
            pointer_dragged = true
        drag_position = event.position
        queue_redraw()

func _pointer_down(position: Vector2) -> void:
    if Rect2(850, 40, 100, 58).has_point(position):
        _request_quit("toolbar_quit")
        return
    if Rect2(720, 40, 110, 58).has_point(position):
        _show_hint()
        return
    pointer_down_position = position
    pointer_dragged = false
    if Rect2(370, 430, 260, 125).has_point(position):
        if first_response_ms < 0:
            first_response_ms = Time.get_ticks_msec()
            _emit("first_response", {"reaction_time_ms": first_response_ms - current_round_started_ms, "input_method": "tap"})
        drag_object = "object"
        drag_position = position
        queue_redraw()
        return
    for region_name in regions:
        var rect: Rect2 = regions[region_name].rect
        if rect.has_point(position) and selected_object != "":
            _attempt_region(region_name, "tap")

func _pointer_up(position: Vector2) -> void:
    if drag_object == "":
        return
    drag_object = ""
    if not pointer_dragged:
        selected_object = "object"
        message = "现在选择一个区域"
        queue_redraw()
        return
    for region_name in regions:
        var rect: Rect2 = regions[region_name].rect
        if rect.has_point(position):
            _attempt_region(region_name, "drag")
            return
    message = "再试一次，把它放进一个区域"
    message_tone = Color("#f9d6a5")
    queue_redraw()

func _attempt_region(region_name: String, input_method: String) -> void:
    var data: Dictionary = rounds[round_index]
    attempt_count += 1
    var is_correct: bool = region_name == str(data.correct)
    _emit("attempt", {"opportunity_id": "GAME004-R%02d" % (round_index + 1), "object": data.object, "selected_region": region_name, "input_method": input_method, "correct": is_correct})
    if is_correct:
        completed_count += 1
        selected_region = region_name
        message = "这里适合它，生态开始运转了"
        message_tone = Color("#b9f6c4")
        feedback_until_ms = Time.get_ticks_msec() + 900
        _emit("success", {"opportunity_id": "GAME004-R%02d" % (round_index + 1), "prompt_level": 0, "first_attempt": attempt_count == completed_count})
        queue_redraw()
        await get_tree().create_timer(0.95).timeout
        if session_status != "started":
            return
        if round_index + 1 >= ROUND_COUNT:
            _complete_game()
        else:
            _start_round(round_index + 1)
    else:
        error_count += 1
        message = "还差一点，我们再看看这个区域"
        message_tone = Color("#f9d6a5")
        _emit("error", {"opportunity_id": "GAME004-R%02d" % (round_index + 1), "error_type": "wrong_region", "selected_region": region_name})
        await get_tree().create_timer(0.35).timeout
        if session_status == "started":
            _show_hint()

func _show_hint() -> void:
    hint_count += 1
    message = "看看区域的样子，再试一次"
    message_tone = Color("#ffe7a3")
    _emit("hint_shown", {"opportunity_id": "GAME004-R%02d" % (round_index + 1), "hint_level": 1, "reason": "repair_after_error"})
    queue_redraw()

func _complete_game() -> void:
    session_status = "completed"
    message = "今天的生态舱完成了"
    message_tone = Color("#b9f6c4")
    _emit("game_complete", {"completed_count": completed_count, "attempt_count": attempt_count, "error_count": error_count, "hint_count": hint_count})
    queue_redraw()

func _request_quit(reason: String) -> void:
    if session_status != "started":
        return
    session_status = "quit"
    _emit("game_quit", {"reason": reason, "completed_count": completed_count, "round_index": round_index + 1})
    _emit("game_result", _result_payload())
    message = "已安全退出"
    queue_redraw()

func _result_payload() -> Dictionary:
    var started := current_round_started_ms > 0
    return {"session_status": session_status, "completed_count": completed_count, "attempt_count": attempt_count, "error_count": error_count, "hint_count": hint_count, "quit_before_finish": session_status != "completed", "stop_used": false, "downgrade_used": false, "safety_event": false, "duration_sec": (Time.get_ticks_msec() - current_round_started_ms) / 1000.0 if started else 0.0}

func _emit(event_type: String, payload: Dictionary) -> void:
    var event: Dictionary = bridge.emit_event(event_type, payload)
    events.append(event)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color("#10243a"))
    draw_circle(Vector2(820, 170), 220, Color("#1f446a"))
    draw_circle(Vector2(820, 170), 160, Color("#203d72"))
    for i in range(12):
        var star := Vector2(680 + (i * 71) % 270, 70 + (i * 47) % 210)
        draw_circle(star, 2.5, Color("#bde8ff"))
    draw_string(ThemeDB.fallback_font, Vector2(70, 90), "星图生态舱", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color("#f5fbff"))
    draw_string(ThemeDB.fallback_font, Vector2(70, 135), "把对象放进合适的区域", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#a9c5dd"))
    draw_rect(Rect2(70, 160, 860, 2), Color("#5f88a6"))
    draw_string(ThemeDB.fallback_font, Vector2(70, 180), "回合 %d / %d" % [mini(round_index + 1, ROUND_COUNT), ROUND_COUNT], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#c7dded"))
    _draw_button(Rect2(720, 40, 110, 58), "提示", Color("#315b77"))
    _draw_button(Rect2(850, 40, 100, 58), "退出", Color("#4d5367"))
    draw_rect(STAGE, Color("#17324b"), true)
    draw_rect(STAGE, Color("#5f88a6"), false, 3)
    for region_name in regions:
        _draw_region(region_name, regions[region_name])
    var data: Dictionary = rounds[round_index]
    var object_pos := drag_position if drag_object != "" else Vector2(500, 495)
    if selected_region != "":
        object_pos = regions[selected_region].rect.get_center()
    _draw_object(object_pos, data.object, data.object_color)
    draw_rect(Rect2(80, 1015, 840, 62), Color("#0d1e31"), true)
    draw_string(ThemeDB.fallback_font, Vector2(105, 1055), message, HORIZONTAL_ALIGNMENT_LEFT, 790, 27, message_tone)
    if session_status != "started":
        draw_rect(Rect2(140, 385, 720, 220), Color(0.04, 0.12, 0.2, 0.94), true)
        draw_rect(Rect2(140, 385, 720, 220), Color("#8bb8cf"), false, 3)
        draw_string(ThemeDB.fallback_font, Vector2(210, 475), message, HORIZONTAL_ALIGNMENT_LEFT, 580, 38, message_tone)
        draw_string(ThemeDB.fallback_font, Vector2(210, 535), "事件已写入本地日志，可交给宿主 App 适配层", HORIZONTAL_ALIGNMENT_LEFT, 580, 22, Color("#b5c9da"))
    if debug_open:
        draw_string(ThemeDB.fallback_font, Vector2(70, 1210), "DEBUG  status=%s  events=%d  attempts=%d  errors=%d  hints=%d" % [session_status, events.size(), attempt_count, error_count, hint_count], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#7fa2bd"))

func _draw_region(name: String, data: Dictionary) -> void:
    var rect: Rect2 = data.rect
    var pulse := 1.0
    if selected_region == name and Time.get_ticks_msec() < feedback_until_ms:
        pulse = 1.08
    var center := rect.get_center()
    var size := rect.size * pulse
    var body := Rect2(center - size / 2.0, size)
    draw_style_box(_box(data.color, 28, data.accent), body)
    draw_circle(center + Vector2(-65, -40), 40, data.accent)
    draw_circle(center + Vector2(55, 55), 24, data.accent.darkened(0.15))
    if name == "水池":
        for i in range(4):
            draw_arc(center + Vector2(-90 + i * 60, 40), 35, 0, PI, 16, Color("#a7f7ff"), 5)
    else:
        for i in range(4):
            var flower := center + Vector2(-90 + i * 60, 35)
            draw_circle(flower, 18, Color("#ffcf66"))
            draw_circle(flower + Vector2(0, 24), 24, Color("#6fb45c"))
    draw_string(ThemeDB.fallback_font, center + Vector2(-120, 125), name, HORIZONTAL_ALIGNMENT_CENTER, 240, 30, Color("#f8fbff"))

func _draw_object(pos: Vector2, label: String, color: Color) -> void:
    draw_circle(pos, 70, Color(0.05, 0.1, 0.16, 0.55))
    draw_circle(pos, 58, color)
    draw_circle(pos - Vector2(18, 18), 16, Color(1, 1, 1, 0.58))
    draw_string(ThemeDB.fallback_font, pos + Vector2(-100, 105), label, HORIZONTAL_ALIGNMENT_CENTER, 200, 27, Color("#f8fbff"))

func _draw_button(rect: Rect2, label: String, color: Color) -> void:
    draw_style_box(_box(color, 12, color.lightened(0.18)), rect)
    draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, 37), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 24, Color("#f4fbff"))

func _box(fill: Color, radius: int, border: Color) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = fill
    box.corner_radius_top_left = radius
    box.corner_radius_top_right = radius
    box.corner_radius_bottom_left = radius
    box.corner_radius_bottom_right = radius
    box.border_width_left = 2
    box.border_width_right = 2
    box.border_width_top = 2
    box.border_width_bottom = 2
    box.border_color = border
    return box
