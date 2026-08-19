extends SceneTree

func _initialize() -> void:
    var file := FileAccess.open("res://configs/gp/GF03-L1-P01.json", FileAccess.READ)
    var config = JSON.parse_string(file.get_as_text()) if file else null
    var failures: Array[String] = []
    if not config is Dictionary: failures.append("L1P01 config unavailable")
    else:
        for round_data in config.get("rounds", []):
            var path := str(round_data.get("correct_region_asset_path", ""))
            if path.is_empty(): failures.append("missing region asset path")
            elif not ResourceLoader.exists(path): failures.append("missing region asset " + path)
    if failures.is_empty():
        print("L1P01_REGION_ASSET_TEST_PASS")
        quit(0)
    for failure in failures: push_error(failure)
    quit(1)
