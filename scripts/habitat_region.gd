class_name HabitatRegion
extends Area2D
## 生态区域：瓦片素材 + 高光响应 + 放置后点亮

signal placed(correct: bool)

@export var region_name: String = ""
@export var texture: Texture2D
@export var tint_normal := Color(1, 1, 1, 1)
@export var tint_glow := Color(1.25, 1.3, 1.15, 1)

var sprite: Sprite2D
var label: Label
var _tween: Tween
var _lit := false

func _ready() -> void:
    # 简洁槽位：圆润半透明底 + 高光描边（不再用整张生态大图）
    var panel := Panel.new()
    panel.position = Vector2(-150, -170)
    panel.size = Vector2(300, 340)
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color(0.94, 0.90, 0.78, 0.35)
    sb.border_color = Color("#a8b894")
    sb.border_width_left = 5; sb.border_width_right = 5
    sb.border_width_top = 5; sb.border_width_bottom = 5
    sb.corner_radius_top_left = 30; sb.corner_radius_top_right = 30
    sb.corner_radius_bottom_left = 30; sb.corner_radius_bottom_right = 30
    panel.add_theme_stylebox_override("panel", sb)
    add_child(panel)
    # 中心图标（对象形状提示）
    var icon := Label.new()
    icon.text = "●" if region_name == "round" else "■"
    icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    icon.position = Vector2(-150, -60)
    icon.size = Vector2(300, 90)
    icon.add_theme_font_size_override("font_size", 72)
    icon.add_theme_color_override("font_color", Color("#6f8a76"))
    add_child(icon)
    # 碰撞区
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(300, 340)
    shape.shape = rect
    add_child(shape)

func set_label_text(t: String) -> void:
    if not label:
        label = Label.new()
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        label.add_theme_font_size_override("font_size", 30)
        label.add_theme_color_override("font_color", Color("#4a5c50"))
        label.position = Vector2(-120, 130)
        label.size = Vector2(240, 40)
        add_child(label)
    label.text = t

func glow() -> void:
    _kill_tween()
    _tween = create_tween()
    _tween.tween_property(self, "modulate", Color(1.2, 1.25, 1.1, 1), 0.4) \
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    _tween.tween_interval(0.6)
    _tween.tween_property(self, "modulate", Color.WHITE, 0.8) \
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _kill_tween() -> void:
    if _tween: _tween.kill()
    _tween = null
