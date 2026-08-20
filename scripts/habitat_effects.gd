class_name HabitatEffects
extends Node2D
## 生态特效层：CPUParticles2D 自然反馈（发光粒子/飘落叶片/水花）

const PALETTE := {
    "leaf": Color("#8fa58b"),
    "glow": Color("#f7e8a0"),
    "water": Color("#9fd4e8"),
    "spark": Color("#fdfaf2"),
}

## 在指定位置播放一段一次性粒子爆发
func burst(kind: String, at: Vector2, count: int = 24) -> void:
    var p := CPUParticles2D.new()
    p.position = at
    p.one_shot = true
    p.explosiveness = 1.0
    p.amount = count
    p.lifetime = 0.9
    p.local_coords = false
    p.direction = Vector2(0, -1)
    p.spread = 180.0
    p.gravity = Vector2(0, 120)
    p.initial_velocity_min = 40.0
    p.initial_velocity_max = 140.0
    p.scale_amount_min = 0.4
    p.scale_amount_max = 1.1
    var col: Color = PALETTE.get(kind, PALETTE["glow"])
    p.color = col
    add_child(p)
    p.emitting = true
    p.finished.connect(p.queue_free)

## 持续柔和光点（放置成功时区域上方）
func ambient_glow(at: Vector2, on: bool) -> CPUParticles2D:
    var p := CPUParticles2D.new()
    p.position = at
    p.amount = 16
    p.lifetime = 2.4
    p.explosiveness = 0.1
    p.local_coords = false
    p.direction = Vector2(0, -1)
    p.spread = 30.0
    p.gravity = Vector2.ZERO
    p.initial_velocity_min = 6.0
    p.initial_velocity_max = 18.0
    p.scale_amount_min = 0.15
    p.scale_amount_max = 0.4
    p.color = Color(0.97, 0.91, 0.62, 0.9)
    p.emitting = on
    add_child(p)
    return p
