extends SceneTree

const EXPECTED := {
    "GF03-L1-P01-R01": "res://assets/processed/objects_v001/red_circle_seed_v001.png",
    "GF03-L1-P01-R02": "res://assets/processed/objects_v001/blue_square_crystal_v001.png",
    "GF03-L1-P01-R03": "res://assets/processed/objects_v001/yellow_star_leaf_v001.png",
    "GF03-L1-P01-R04": "res://assets/processed/objects_v001/green_triangle_stone_v001.png",
    "GF03-L1-P01-R05": "res://assets/processed/objects_v001/white_round_drop_v001.png",
    "GF03-L1-P01-R06": "res://assets/processed/objects_v001/purple_square_tool_v001.png"
}

func _initialize() -> void:
    var file := FileAccess.open("res://configs/gp/GF03-L1-P01.json", FileAccess.READ)
    var config = JSON.parse_string(file.get_as_text()) if file else null
    var failures: Array[String] = []
    if not config is Dictionary: failures.append("L1P01 config unavailable")
    else:
        for round_data in config.get("rounds", []):
            var id := str(round_data.get("opportunity_id", ""))
            var path := str(round_data.get("target_asset_path", ""))
            if not EXPECTED.has(id): failures.append("unexpected round " + id)
            elif path != EXPECTED[id]: failures.append("asset map mismatch " + id)
            elif not ResourceLoader.exists(path): failures.append("missing object asset " + path)
    if failures.is_empty():
        print("L1P01_OBJECT_ASSET_TEST_PASS")
        quit(0)
    for failure in failures: push_error(failure)
    quit(1)
