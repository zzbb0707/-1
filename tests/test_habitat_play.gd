extends SceneTree
## habitat 场景自动化玩法测试：验证拖拽判定/回合推进/完成事件

var _game: Node
var _pass := 0
var _fail := 0
var _started := false

func _init() -> void:
    # SceneTree 脚本：在 _process 里延迟执行（_init 不能 await 帧）
    pass

func _process(_delta: float) -> bool:
    if not _started:
        _started = true
        _run()
        return false
    return false

func _run() -> void:
    # 加载 L1P03（蓝方→方区，圆区/方区）
    var scene := load("res://scenes/habitat_slice.tscn")
    _game = scene.instantiate()
    root.add_child(_game)
    await process_frame
    await process_frame

    var g = _game
    _check("有6回合配置", g._rounds.size() == 6)
    _check("回合索引0", g._round_index == 0)
    _check("有当前对象", g.current_object != null)

    # 模拟：把对象移动到正确区域中心再放置
    var obj = g.current_object
    var correct_name: String = obj.correct_region
    _check("正确区域名非空", correct_name != "")
    var rects: Dictionary = obj.region_rects
    _check("区域rect存在", rects.has(correct_name))
    obj.global_position = (rects[correct_name] as Rect2).get_center() + Vector2(0, 20)
    obj._resolve_drop()
    # _on_dropped 成功分支有 0.9s 定时器，等待足够时间
    await create_timer(1.3).timeout
    _check("正确放置后推进回合", g._round_index >= 1 or g.session_status == "completed")
    _check("成功计数>0", g.completed_count > 0 or g.session_status == "completed")

    # 验证跨日文件写入
    var dp := FileAccess.open("user://game004_daily_progress.json", FileAccess.READ)
    _check("跨日文件存在", dp != null)
    if dp:
        dp.close()

    print("HABITAT_PLAY_TEST pass=%d fail=%d" % [_pass, _fail])
    quit(0 if _fail == 0 else 1)

func _check(label: String, cond: bool) -> void:
    if cond:
        _pass += 1
        print("  PASS %s" % label)
    else:
        _fail += 1
        print("  FAIL %s" % label)
