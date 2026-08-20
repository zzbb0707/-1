extends Node2D
## 生态舱外壳层：暖米白圆角舱体 + 鼠尾草绿生态渐变背景
## 通过编程生成柔和的舱体背景，作为全屏场景基底

const SHELL_TOP := Color("#f7f2e4")
const SHELL_BOTTOM := Color("#e8e0c8")
const SAGE := Color("#8fa58b")
const SAGE_DARK := Color("#5f7a66")
const IVORY := Color("#fdfaf2")

# 可选：外部生态舱外壳贴图（如果以后有资产）
@export var shell_texture: Texture2D

var view_size := Vector2(1000, 1250)

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    # 全屏暖米白底
    draw_rect(Rect2(Vector2.ZERO, view_size), IVORY)
    # 顶部柔和渐变：从米白到鼠尾草绿
    var top := Rect2(Vector2(0, 0), Vector2(view_size.x, view_size.y * 0.34))
    _draw_vertical_gradient(top, SHELL_TOP, SHELL_BOTTOM)
    # 底部深一点，营造舱体厚度
    var bottom := Rect2(Vector2(0, view_size.y - view_size.y * 0.16), Vector2(view_size.x, view_size.y * 0.16))
    _draw_vertical_gradient(bottom, Color(0.87, 0.84, 0.72, 0.0), Color(0.82, 0.78, 0.64, 0.5))
    # 圆角舱体描边：柔和的鼠尾草绿边框
    var shell := Rect2(Vector2(18, 18), view_size - Vector2(36, 36))
    draw_style_box(_shell_box(), shell)

func _draw_vertical_gradient(rect: Rect2, top_color: Color, bottom_color: Color) -> void:
    var steps := 24
    var step_h := rect.size.y / steps
    for i in steps:
        var t := float(i) / float(steps - 1)
        var c := top_color.lerp(bottom_color, t)
        c.a = 0.28
        draw_rect(Rect2(rect.position + Vector2(0, step_h * i), Vector2(rect.size.x, step_h + 1)), c)

func _shell_box() -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = Color(1, 1, 1, 0.0)
    box.border_color = SAGE_DARK
    box.border_width_left = 6
    box.border_width_right = 6
    box.border_width_top = 6
    box.border_width_bottom = 6
    box.corner_radius_top_left = 44
    box.corner_radius_top_right = 44
    box.corner_radius_bottom_left = 44
    box.corner_radius_bottom_right = 44
    return box
