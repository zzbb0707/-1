# GAME-004 Godot 4 实战技能手册 V1

来源：Godot 官方文档 + 社区技能库（Godot GDScript Patterns / Animation / Particles / Architecture），2026 整理。
用途：将 GAME-004 从"代码画UI的灰盒"重构为"正规场景+动画+特效的游戏"。

## 1. 核心原则：Call Down, Signal Up

- 父节点调用子节点方法：`$Child.do_thing()`
- 子节点向上发信号：`signal happened.emit()`
- 兄弟节点由共同父节点在 `_ready()` 里接线
- **绝不用 `get_parent()` 调父方法**

## 2. 场景系统（替代 _draw 画UI）

```
Node（基础）
├── Scene（可复用节点树，.tscn）
├── Resource（数据容器，.tres）
├── Signal（事件通信）
└── Group（节点分组）
```

- `@onready var sprite: Sprite2D = $Sprite2D`
- `@export` 让 Inspector 可编辑
- 节点初始化顺序：`_init()` → `_enter_tree()` → `_ready()`（子先父后）→ `_process()`（父先子后）

## 3. Tween（动态/过渡，核心）

```gdscript
# 创建于任意节点，顺序执行
var t := create_tween()
t.tween_property(self, "position", Vector2(200, 0), 0.5)
t.tween_property(self, "modulate:a", 0.0, 0.3)   # 子属性路径用冒号

# 缓动
t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
t.tween_property($Sprite2D, "position:y", -50.0, 0.4).as_relative()

# 并行 + 链式
t.set_parallel()
t.tween_property(self, "position", target, 0.5)
t.tween_property(self, "scale", Vector2.ONE, 0.5)
t.chain().tween_callback(_on_arrived)

# 循环/等待
create_tween().set_loops(3).tween_property(...)
t.tween_interval(0.25)
await t.finished

# 生命周期
t.bind_node(node)          # 节点释放时tween随之死亡
```

- 短促动态用 Tween；复杂多轨关键帧用 AnimationPlayer；动画状态机用 AnimationTree

## 4. 粒子特效（Compatibility渲染器用CPU）

- 本项目用 GL Compatibility 渲染器 → **优先 CPUParticles2D**（GPU粒子在Compatibility上可能异常）
- 一击即灭的爆发（发芽/点亮/水流）：
```gdscript
func spawn_burst(fx: CPUParticles2D, at: Vector2) -> void:
    fx.global_position = at
    fx.one_shot = true
    fx.emitting = true
    fx.finished.connect(fx.queue_free)
```
- 常驻开关：`fx.emitting = condition`
- `local_coords = false` 让粒子留在世界空间（轨迹正确）

## 5. 精灵动画

- `AnimatedSprite2D` + `SpriteFrames`：逐帧动画 `play("walk")`、`animation_finished`
- 精灵表用 `Sprite2D` + `hframes/vframes`，AnimationPlayer 关键帧 `frame`
- 拖拽交互：InputEvent 判断 + Tween 跟随 + drop 到区域

## 6. 素材透明化（消除"带背景贴图"问题）

- AI生成图带暖米白底 → 抠图：
  - Godot 导入时 `ResourceImporterTextureAtlas` / 编辑器 TextureRegion 切分
  - 或外部抠图后导入带 alpha 的 PNG
- Sprite2D 设置 `texture_filter = TEXTURE_FILTER_LINEAR` 避免锯齿

## 7. Autoload 事件总线

```ini
[autoload]
GameState="*res://scripts/autoload/game_state.gd"
Events="*res://scripts/autoload/events.gd"
```

游戏状态、桥事件、跨日状态放 autoload，跨场景存活。

## 8. 场景切换

```gdscript
get_tree().change_scene_to_file("res://scenes/xxx.tscn")
```

## 本项目的落地计划

1. 用 **Sprite2D + 场景节点** 重构舞台（生态舱外壳背景、区域瓦片、对象）
2. 素材先**抠图透明化**再放场景
3. 用 **Tween** 做：对象拾取/拖拽/放置、结果生长、区域点亮过渡
4. 用 **CPUParticles2D** 做：发芽/水流/灯亮的自然特效
5. 保留现有配置/桥/跨日逻辑，替换渲染层
