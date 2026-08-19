extends SceneTree

const ASSET_ROOT := "res://assets/candidates/image2/assets_v001"
const REQUIRED := [
    "GAME004_asset_stage_shell_v001.png",
    "GAME004_asset_region_water_v001.png",
    "GAME004_asset_region_forest_v001.png",
    "GAME004_asset_region_sun_v001.png",
    "GAME004_asset_region_tool_v001.png",
    "GAME004_asset_object_water_seed_v001.png",
    "GAME004_asset_object_sun_seed_v001.png",
    "GAME004_asset_object_moss_bud_v001.png",
    "GAME004_asset_object_tool_v001.png",
    "GAME004_asset_rule_icons_v001.png"
]

func _initialize() -> void:
    var failures: Array[String] = []
    var manifest_path := ASSET_ROOT + "/generation_manifest.json"
    if not FileAccess.file_exists(manifest_path):
        failures.append("manifest missing")
    for filename in REQUIRED:
        var path: String = ASSET_ROOT + "/" + filename
        if not FileAccess.file_exists(path):
            failures.append("asset missing: " + filename)
            continue
        var image := Image.load_from_file(path)
        if image.is_empty(): failures.append("asset unreadable: " + filename)
    if failures.is_empty():
        print("ASSET_CANDIDATE_TEST_PASS")
        quit(0)
    for failure in failures: push_error(failure)
    quit(1)
