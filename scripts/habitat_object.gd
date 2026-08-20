class_name HabitatObject
extends Area2D
## 可拖拽的生态对象：透明素材 + Tween拖拽 + 放置反馈

signal dropped(correct: bool, region_name: String)

@export var texture: Texture2D
@export var correct_region: String = ""
@export var region_rects: Dictionary = {}  # region_name -> Rect2
@export var idle_offset := Vector2.ZERO

var sprite: Sprite2D
var _dragging := false
var _start_pos := Vector2.ZERO
var _tween: Tween

func _ready() -> void:
    sprite = Sprite2D.new()
    sprite.texture = texture
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    sprite.centered = true
    add_child(sprite)
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = max(sprite.texture.get_width(), sprite.texture.get_height()) * 0.5
    shape.shape = circle
    add_child(shape)
    _start_pos = position

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            var local := to_local(event.position)
            if sprite.get_rect().has_point(local + sprite.offset):
                _dragging = true
                _kill_tween()
                z_index = 10
        elif _dragging:
            _dragging = false
            _resolve_drop()
    elif event is InputEventMouseMotion and _dragging:
        position = get_global_mouse_position()

func _resolve_drop() -> void:
    var drop_region := ""
    for rname in region_rects:
        var rect: Rect2 = region_rects[rname]
        if rect.has_point(global_position):
            drop_region = rname
            break
    if drop_region != "":
        var correct := drop_region == correct_region
        if correct:
            _fly_to(region_rects[drop_region].get_center() + Vector2(0, 40))
        else:
            _bounce_back()
        dropped.emit(correct, drop_region)
    else:
        _bounce_back()

func _fly_to(target: Vector2) -> void:
    _kill_tween()
    _tween = create_tween()
    _tween.tween_property(self, "global_position", target, 0.35) \
        .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    _tween.tween_property(self, "scale", Vector2.ONE * 0.92, 0.2)

func _bounce_back() -> void:
    _kill_tween()
    _tween = create_tween()
    _tween.tween_property(self, "position", _start_pos, 0.4) \
        .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _kill_tween() -> void:
    if _tween: _tween.kill()
    _tween = null
