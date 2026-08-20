extends SceneTree
## outcome 显示验证（配合 --write-movie）：放置后停留，让 movie 录到结果图标

var _game: Node
var _started := false

func _init() -> void:
    pass

func _process(_delta: float) -> bool:
    if not _started:
        _started = true
        _run()
        return false
    return false

func _run() -> void:
    var scene := load("res://scenes/habitat_slice.tscn")
    _game = scene.instantiate()
    root.add_child(_game)
    await process_frame
    await process_frame
    var g = _game
    var obj = g.current_object
    var correct_name: String = obj.correct_region
    var rects: Dictionary = obj.region_rects
    obj.global_position = (rects[correct_name] as Rect2).get_center() + Vector2(0, 20)
    obj._resolve_drop()
    # 停留 3 秒（movie maker 会录到 outcome 显示 + 下一回合）
    await create_timer(3.0).timeout
    print("OUTCOME_SHOW_TEST_DONE")
    quit(0)
