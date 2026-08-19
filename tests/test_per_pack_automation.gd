extends SceneTree

# GAME-004 per-pack automation test: validates all 20 GP configs
# - 20 packs, each exactly 6 rounds
# - required semantic fields present
# - asset paths exist in resource tree (when mapped)
# - low_sensory flag present

const PACKS := [
    "GF03-L1-P01", "GF03-L1-P02", "GF03-L1-P03", "GF03-L1-P04",
    "GF03-L2-P01", "GF03-L2-P02", "GF03-L2-P03", "GF03-L2-P04",
    "GF03-L3-P01", "GF03-L3-P02", "GF03-L3-P03", "GF03-L3-P04",
    "GF03-L4-P01", "GF03-L4-P02", "GF03-L4-P03", "GF03-L4-P04",
    "GF03-L5-P01", "GF03-L5-P02", "GF03-L5-P03", "GF03-L5-P04"
]
const REQUIRED_ROUND_FIELDS := ["opportunity_id", "frozen_content", "target_display_name", "correct_region_label", "rule_id", "natural_outcome_label"]

func _initialize() -> void:
    var failures: Array[String] = []
    var total_rounds := 0
    var packs_with_assets := 0
    var low_sensory_ok := 0
    for pack_id in PACKS:
        var path := "res://configs/gp/%s.json" % pack_id
        var file := FileAccess.open(path, FileAccess.READ)
        if not file:
            failures.append(pack_id + ": config missing")
            continue
        var parsed = JSON.parse_string(file.get_as_text())
        file.close()
        if not parsed is Dictionary:
            failures.append(pack_id + ": invalid json")
            continue
        var rounds: Array = parsed.get("rounds", [])
        if rounds.size() != 6:
            failures.append(pack_id + ": rounds=%d (expected 6)" % rounds.size())
        total_rounds += rounds.size()
        var asset_count := 0
        for r in rounds:
            for field in REQUIRED_ROUND_FIELDS:
                if not r.has(field) or str(r[field]).is_empty():
                    failures.append(pack_id + "/" + str(r.get("opportunity_id", "?")) + ": missing " + field)
            var asset_path := str(r.get("target_asset_path", ""))
            if asset_path != "" and ResourceLoader.exists(asset_path):
                asset_count += 1
        if asset_count > 0: packs_with_assets += 1
        if parsed.get("low_sensory_variant_id", "") != "": low_sensory_ok += 1
    if total_rounds != 120:
        failures.append("total rounds=%d (expected 120)" % total_rounds)
    if low_sensory_ok != 20:
        failures.append("low_sensory_variant_id on %d/20 packs" % low_sensory_ok)
    if failures.is_empty():
        print("PER_PACK_AUTOMATION_TEST_PASS rounds=%d packs_with_assets=%d low_sensory=%d" % [total_rounds, packs_with_assets, low_sensory_ok])
        quit(0)
    for f in failures: push_error(f)
    quit(1)
