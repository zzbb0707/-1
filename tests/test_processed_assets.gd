extends SceneTree

func _initialize() -> void:
    var dir := DirAccess.open("res://assets/processed/v001")
    if dir == null:
        push_error("processed asset directory missing")
        quit(1)
        return
    var count := 0
    dir.list_dir_begin()
    var name := dir.get_next()
    while name != "":
        if name.ends_with(".png"):
            var image := Image.load_from_file("res://assets/processed/v001/" + name)
            if image.is_empty(): push_error("unreadable: " + name)
            count += 1
        name = dir.get_next()
    dir.list_dir_end()
    if count != 10:
        push_error("expected 10 processed assets, got %d" % count)
        quit(1)
        return
    print("PROCESSED_ASSET_TEST_PASS")
    quit(0)
