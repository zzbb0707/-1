class_name HabitatGame
extends Node2D
## L1P03 精品切片主控：组装背景/区域/对象/特效/UI，跑一回合

const REGION_SCRIPT := preload("res://scripts/habitat_region.gd")
const OBJECT_SCRIPT := preload("res://scripts/habitat_object.gd")
const EFFECTS_SCRIPT := preload("res://scripts/habitat_effects.gd")
const AppBridgeScript := preload("res://scripts/app_bridge.gd")

var bridge = AppBridgeScript.new()
var events: Array = []
var launch_context: Dictionary = {
    "schema_version": "game-bridge-v1", "task_id": "GAME-004",
    "game_config_id": "GAMECFG-GAME-004-GF03", "task_session_id": "preview-session",
    "child_profile_id": "preview-child", "daily_plan_id": "preview-plan", "debug": false,
    "low_sensory": false, "launch_mode": "preview", "content_version": "GAME-004-V2",
    "ruleset_version": "GAME004-SLICE-V1"
}
var low_sensory := false
var attempt_count := 0
var error_count := 0
var hint_count := 0
var completed_count := 0
var session_started_ms := 0
var session_status := "started"

var effects: HabitatEffects
var current_object: HabitatObject
var _ui: CanvasLayer
var _title_label: Label
var _round_label: Label
var _message_label: Label
var _hint_btn: Button
var _exit_btn: Button

# 配置驱动：任意包六回合
var _pack_id := "GF03-L1-P03"
var _rounds: Array = []
var _round_index := 0
var _correct_count := 0
var _region_a: HabitatRegion
var _region_b: HabitatRegion
var _region_a_name := ""
var _region_b_name := ""

func _ready() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg == "--low-sensory": low_sensory = true
    bridge.load_context(launch_context)
    session_started_ms = Time.get_ticks_msec()
    _load_config()
    _build_shell()
    effects = EFFECTS_SCRIPT.new()
    add_child(effects)
    _build_ui()
    _build_regions()
    _spawn_round(0)
    _emit("game_start", {"game_pack_id": _pack_id, "round_count": _rounds.size(), "low_sensory": low_sensory})

func _emit(event_type: String, payload: Dictionary) -> void:
    var ev := bridge.emit_event(event_type, payload)
    events.append(ev)

func _load_config() -> void:
    var pack := "GF03-L1-P03"
    # 支持 --game-pack=xxx 参数
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--game-pack="):
            pack = arg.trim_prefix("--game-pack=")
    _pack_id = pack
    var f := FileAccess.open("res://configs/gp/%s.json" % pack, FileAccess.READ)
    if f:
        var data: Dictionary = JSON.parse_string(f.get_as_text())
        if data.has("rounds"):
            _rounds = data["rounds"]

func _load_assets() -> void:
    # 无全局预加载，改为按回合 load
    pass

func _build_shell() -> void:
    # 背景统一为暖米白全屏 + 柔和顶部光晕（避免外壳深蓝与UI冲突）
    var bg := ColorRect.new()
    bg.color = Color("#f2ecdd")
    bg.position = Vector2(-50, -50)
    bg.size = Vector2(1100, 1350)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)
    # 顶部柔光：米白到鼠尾草绿
    var top_glow := ColorRect.new()
    top_glow.color = Color(0.56, 0.65, 0.55, 0.18)
    top_glow.position = Vector2(-50, -50)
    top_glow.size = Vector2(1100, 420)
    top_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(top_glow)

func _build_ui() -> void:
    _ui = CanvasLayer.new()
    add_child(_ui)

    # 顶部标题带（暖米白圆角卡片）
    var top_panel := Panel.new()
    top_panel.position = Vector2(30, 24)
    top_panel.size = Vector2(940, 110)
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color("#efe8d2")
    sb.corner_radius_top_left = 20; sb.corner_radius_top_right = 20
    sb.corner_radius_bottom_left = 20; sb.corner_radius_bottom_right = 20
    sb.border_color = Color("#c9bd99"); sb.border_width_left = 3
    sb.border_width_right = 3; sb.border_width_top = 3; sb.border_width_bottom = 3
    top_panel.add_theme_stylebox_override("panel", sb)
    _ui.add_child(top_panel)

    _title_label = Label.new()
    _title_label.text = "星图生态舱 | %s" % _pack_id
    _title_label.position = Vector2(58, 34)
    _title_label.size = Vector2(700, 44)
    _title_label.add_theme_font_size_override("font_size", 30)
    _title_label.add_theme_color_override("font_color", Color("#33473f"))
    _ui.add_child(_title_label)

    _round_label = Label.new()
    _round_label.text = "回合 1 / 2"
    _round_label.position = Vector2(58, 84)
    _round_label.size = Vector2(700, 32)
    _round_label.add_theme_font_size_override("font_size", 22)
    _round_label.add_theme_color_override("font_color", Color("#6b7d6e"))
    _ui.add_child(_round_label)

    # 右侧按钮
    _hint_btn = Button.new()
    _hint_btn.text = "提示"
    _hint_btn.position = Vector2(780, 40)
    _hint_btn.size = Vector2(84, 56)
    _style_button(_hint_btn, Color("#8fa58b"))
    _hint_btn.pressed.connect(_on_hint)
    _ui.add_child(_hint_btn)

    _exit_btn = Button.new()
    _exit_btn.text = "退出"
    _exit_btn.position = Vector2(878, 40)
    _exit_btn.size = Vector2(84, 56)
    _style_button(_exit_btn, Color("#a68f8a"))
    _exit_btn.pressed.connect(_on_exit)
    _ui.add_child(_exit_btn)

    # 底部消息条
    var msg_panel := Panel.new()
    msg_panel.position = Vector2(30, 1180)
    msg_panel.size = Vector2(940, 56)
    var msb := StyleBoxFlat.new()
    msb.bg_color = Color(0.95, 0.92, 0.84, 0.94)
    msb.corner_radius_top_left = 16; msb.corner_radius_top_right = 16
    msb.corner_radius_bottom_left = 16; msb.corner_radius_bottom_right = 16
    msg_panel.add_theme_stylebox_override("panel", msb)
    _ui.add_child(msg_panel)

    _message_label = Label.new()
    _message_label.text = "把对象放到正确的区域吧"
    _message_label.position = Vector2(60, 1196)
    _message_label.size = Vector2(880, 30)
    _message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _message_label.add_theme_font_size_override("font_size", 24)
    _message_label.add_theme_color_override("font_color", Color("#4a5c50"))
    _ui.add_child(_message_label)

func _style_button(btn: Button, color: Color) -> void:
    var sb := StyleBoxFlat.new()
    sb.bg_color = color
    sb.corner_radius_top_left = 14; sb.corner_radius_top_right = 14
    sb.corner_radius_bottom_left = 14; sb.corner_radius_bottom_right = 14
    btn.add_theme_stylebox_override("normal", sb)
    var hover := StyleBoxFlat.new()
    hover.bg_color = color.lightened(0.15)
    hover.corner_radius_top_left = 14; hover.corner_radius_top_right = 14
    hover.corner_radius_bottom_left = 14; hover.corner_radius_bottom_right = 14
    btn.add_theme_stylebox_override("hover", hover)
    btn.add_theme_font_size_override("font_size", 24)
    btn.add_theme_color_override("font_color", Color("#fdfaf2"))

func _on_hint() -> void:
    _message_label.text = "提示：观察对象形状，放到形状相同的区域"

func _on_exit() -> void:
    get_tree().quit()

func _build_regions() -> void:
    # 从第一回合的 region_set 建两个槽位（正确区 + 干扰区）
    var r: Dictionary = _rounds[0] if not _rounds.is_empty() else {}
    var region_set: Array = r.get("region_set", ["正确区域", "其他区域"])
    _region_a_name = str(region_set[0] if region_set.size() > 0 else "区域A")
    _region_b_name = str(region_set[1] if region_set.size() > 1 else "区域B")

    _region_a = REGION_SCRIPT.new()
    _region_a.region_name = _region_a_name
    _region_a.position = Vector2(260, 640)
    _region_a.texture = _match_region_texture(_region_a_name)
    _region_a.set_label_text(_region_a_name)
    add_child(_region_a)

    _region_b = REGION_SCRIPT.new()
    _region_b.region_name = _region_b_name
    _region_b.position = Vector2(740, 640)
    _region_b.texture = _match_region_texture(_region_b_name)
    _region_b.set_label_text(_region_b_name)
    add_child(_region_b)

func _match_region_texture(region_name: String) -> Texture2D:
    # 按区域名关键词匹配生态瓦片素材（找不到返回 null → 简洁槽位）
    var candidates := {
        "水": "res://assets/processed/v001/GAME004_asset_region_water_v001.png",
        "林": "res://assets/processed/v001/GAME004_asset_region_forest_v001.png",
        "阳光": "res://assets/processed/v001/GAME004_asset_region_sun_v001.png",
        "光": "res://assets/processed/v001/GAME004_asset_region_sun_v001.png",
        "工具": "res://assets/processed/v001/GAME004_asset_region_tool_v001.png",
    }
    for kw in candidates:
        if region_name.contains(kw):
            var p := candidates[kw]
            if ResourceLoader.exists(p):
                return load(p)
    # 天空区专用：skyperch 素材（更贴"天空"语义）
    if region_name.contains("天空"):
        var sky := "res://assets/candidates/banana/approved_candidate/region_skyperch_v001.jpg"
        if ResourceLoader.exists(sky):
            return load(sky)
    # 兜底：banana 区域素材按名匹配
    var fname := "res://assets/candidates/banana/approved_candidate/region_%s_grid_v001.png" % _region_slug(region_name)
    if ResourceLoader.exists(fname):
        return load(fname)
    return null

func _region_slug(region_name: String) -> String:
    var map := {
        "圆区": "round_zone", "方区": "square_zone",
        "水生": "aquatic_zone", "水": "aquatic_zone",
        "天空": "flying", "飞行": "flying",
        "花园": "food_zone", "工具台": "tools_zone", "工具": "tools_zone",
        "食物": "food_zone", "交通": "traffic", "餐具": "kitchen_zone",
        "厨房": "kitchen_zone", "穿戴": "clothing", "衣物": "clothing",
        "土地区": "land_zone", "陆地": "land_zone", "岩": "land_zone",
        "光区": "bluelight_zone", "蓝光": "bluelight_zone", "蓝区": "blue_zone",
        "植物": "plant", "玩具": "toys_zone", "清洁": "cleaning_zone",
        "水果": "fruit_zone", "中区": "medium_zone", "小区": "small_zone",
        "卧室": "bedroom_zone", "阅读": "book_zone",
        "红区": "red_zone", "黄区": "yellow_zone", "敲击": "tapping_zone",
        "维修": "tools_zone", "主食": "food_zone", "用品": "clothing",
        "范例": "example_zone", "同图": "matching_image", "大区": "big_zone",
        "正确配对": "matching_image",
    }
    for k in map:
        if region_name.contains(k):
            return map[k]
    return ""

func _spawn_round(round_no: int) -> void:
    _round_index = round_no
    if current_object:
        current_object.queue_free()
        current_object = null
    if round_no >= _rounds.size():
        _finish_game()
        return

    var r: Dictionary = _rounds[round_no]
    var obj_path := str(r.get("target_asset_path", ""))
    var tex: Texture2D = null
    if obj_path != "" and ResourceLoader.exists(obj_path):
        # 优先用抠图透明版
        var base := obj_path.get_file().get_basename()
        var cutout := "res://assets/processed/cutout_v001/%s_alpha.png" % base
        if ResourceLoader.exists(cutout):
            tex = load(cutout)
        else:
            tex = load(obj_path)

    # 正确区域名来自配置 correct_region_label
    var correct := _region_a_name
    if str(r.get("correct_region_label", "")).contains(_region_b_name):
        correct = _region_b_name
    elif str(r.get("correct_region_label", "")).contains(_region_a_name):
        correct = _region_a_name

    current_object = OBJECT_SCRIPT.new()
    current_object.texture = tex
    current_object.correct_region = correct
    current_object.region_rects = {
        _region_a_name: Rect2(Vector2(260 - 150, 640 - 170), Vector2(300, 340)),
        _region_b_name: Rect2(Vector2(740 - 150, 640 - 170), Vector2(300, 340)),
    }
    current_object.position = Vector2(500, 430)
    current_object.scale = Vector2(0.7, 0.7)
    current_object.dropped.connect(_on_dropped)
    add_child(current_object)
    _round_label.text = "回合 %d / %d" % [round_no + 1, _rounds.size()]
    _message_label.text = "把 %s 放到正确的区域" % str(r.get("target_display_name", "对象"))
    _emit("opportunity_presented", {
        "game_pack_id": _pack_id, "round_index": round_no + 1, "round_total": _rounds.size(),
        "target": str(r.get("target_display_name", "")), "correct_region": correct,
    })

func _on_dropped(correct: bool, region_name: String) -> void:
    attempt_count += 1
    var target: HabitatRegion = _region_a if region_name == _region_a_name else _region_b
    if correct:
        completed_count += 1
        if not low_sensory:
            target.glow()
            effects.burst("glow", target.position + Vector2(0, 20))
        _message_label.text = "太棒了！区域启动了"
        _emit("success", {"round_index": _round_index + 1, "attempt_count": attempt_count})
        await get_tree().create_timer(0.9).timeout
        _spawn_round(_round_index + 1)
    else:
        error_count += 1
        if not low_sensory:
            effects.burst("spark", current_object.position, 10)
        _message_label.text = "再试一次，看看哪个区域"
        _emit("error", {"round_index": _round_index + 1, "attempt_count": attempt_count, "error_count": error_count})

func _finish_game() -> void:
    _message_label.text = "全部完成！你真是太棒了"
    session_status = "completed"
    if current_object:
        current_object.queue_free()
        current_object = null
    if not low_sensory:
        effects.burst("glow", Vector2(500, 400), 40)
        effects.burst("glow", Vector2(300, 500), 30)
        effects.burst("glow", Vector2(700, 500), 30)
    _emit("game_complete", {
        "game_pack_id": _pack_id, "completed_count": completed_count,
        "attempt_count": attempt_count, "error_count": error_count,
        "duration_sec": (Time.get_ticks_msec() - session_started_ms) / 1000.0,
    })
    bridge.build_result(session_status, {
        "game_pack_id": _pack_id, "completed_count": completed_count,
        "attempt_count": attempt_count, "error_count": error_count,
    })
