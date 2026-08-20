extends SceneTree
## habitat 完整通关测试：自动完成全部 6 回合，验证整包可玩

var _game: Node
var _pass := 0
var _fail := 0
var _started := false

func _init() -> void:
    pass

func _process(_delta: float) -> bool:
    if not _started:
        _started = true
        _run_completion()
        return false
    return false

func _run_completion() -> void:
    var scene := load("res://scenes/habitat_slice.tscn")
    _game = scene.instantiate()
    root.add_child(_game)
    await process_frame
    await process_frame

    var g = _game
    _check("配置6回合", g._rounds.size() == 6)

    # 自动通关：最多循环 30 次（每回合 0.9s 定时器）
    var rounds_completed := 0
    for i in 30:
        await create_timer(1.0).timeout
        if g.session_status == "completed":
            break
        if g.current_object == null:
            continue
        var obj = g.current_object
        var correct_name: String = obj.correct_region
        var rects: Dictionary = obj.region_rects
        if rects.has(correct_name):
            obj.global_position = (rects[correct_name] as Rect2).get_center() + Vector2(0, 20)
            obj._resolve_drop()

    _check("完成状态=completed", g.session_status == "completed")
    _check("完成计数=6", g.completed_count >= 6)
    _check("回合索引到末尾", g._round_index >= 6)
    _check("跨日文件写入", FileAccess.file_exists("user://game004_daily_progress.json"))

    print("HABITAT_COMPLETION_TEST pass=%d fail=%d rounds=%d" % [_pass, _fail, g.completed_count])
    quit(0 if _fail == 0 else 1)

func _check(label: String, cond: bool) -> void:
    if cond:
        _pass += 1
        print("  PASS %s" % label)
    else:
        _fail += 1
        print("  FAIL %s" % label)
