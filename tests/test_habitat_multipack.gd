extends SceneTree
## habitat 多包通关测试：验证不同难度包都能完整玩完

var _pass := 0
var _fail := 0
var _started := false
var _packs := ["GF03-L1-P01", "GF03-L1-P02", "GF03-L1-P03", "GF03-L1-P04",
    "GF03-L2-P01", "GF03-L2-P02", "GF03-L2-P03", "GF03-L2-P04",
    "GF03-L3-P01", "GF03-L3-P02", "GF03-L3-P03", "GF03-L3-P04",
    "GF03-L4-P01", "GF03-L4-P02", "GF03-L4-P03", "GF03-L4-P04",
    "GF03-L5-P01", "GF03-L5-P02", "GF03-L5-P03", "GF03-L5-P04"]
var _idx := 0

func _init() -> void:
    pass

func _process(_delta: float) -> bool:
    if not _started:
        _started = true
        _run_next()
        return false
    return false

func _run_next() -> void:
    if _idx >= _packs.size():
        print("HABITAT_MULTIPACK_TEST pass=%d fail=%d" % [_pass, _fail])
        quit(0 if _fail == 0 else 1)
        return
    var pack: String = _packs[_idx]
    var scene := load("res://scenes/habitat_slice.tscn") as PackedScene
    var game: Node = scene.instantiate()
    root.add_child(game)
    await process_frame
    await process_frame
    # 设置包
    game._pack_id = pack
    game._load_config()
    # 重建区域（配置变化后）
    for c in game.get_children():
        if c is HabitatRegion or c is HabitatObject:
            c.queue_free()
    game._build_regions()
    game._spawn_round(0)
    await process_frame

    var rounds_done := 0
    for i in 40:
        await create_timer(1.0).timeout
        if game.session_status == "completed":
            break
        if game.current_object == null:
            continue
        var obj = game.current_object
        var correct_name: String = obj.correct_region
        var rects: Dictionary = obj.region_rects
        if rects.has(correct_name):
            obj.global_position = (rects[correct_name] as Rect2).get_center() + Vector2(0, 20)
            obj._resolve_drop()

    var ok: bool = game.session_status == "completed" and game.completed_count >= 6
    if ok:
        _pass += 1
        print("  PASS %s 完整通关 rounds=%d" % [pack, game.completed_count])
    else:
        _fail += 1
        print("  FAIL %s status=%s completed=%d" % [pack, game.session_status, game.completed_count])

    game.queue_free()
    await process_frame
    _idx += 1
    _run_next()

func _check(label: String, cond: bool) -> void:
    if cond:
        _pass += 1
    else:
        _fail += 1
