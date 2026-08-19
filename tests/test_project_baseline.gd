extends SceneTree

const EXPECTED_SOURCE_SHA := "B22F6552220C0EC9932576903C531C074184E0A32CF7B10ADEAFD7057F78DF22"

func _initialize() -> void:
    var failures: Array[String] = []
    if not FileAccess.file_exists("res://PROJECT_BASELINE.md"): failures.append("PROJECT_BASELINE.md missing")
    var file := FileAccess.open("res://baseline/game004_content_baseline.json", FileAccess.READ)
    if not file:
        failures.append("content baseline missing")
    else:
        var root = JSON.parse_string(file.get_as_text())
        if not root is Dictionary:
            failures.append("content baseline invalid JSON")
        else:
            if root.get("baseline_version") != "GAME004-BASELINE-V1": failures.append("baseline version mismatch")
            if root.get("game_id") != "GAME-004" or root.get("game_family_id") != "GF-03" or root.get("primary_training_unit_id") != "TU-011": failures.append("parent mapping mismatch")
            if int(root.get("pack_count", 0)) != 20: failures.append("pack_count must be 20")
            if int(root.get("opportunity_count", 0)) != 120: failures.append("opportunity_count must be 120")
            if root.get("source_sha256") != EXPECTED_SOURCE_SHA: failures.append("authoritative source hash mismatch")
            var packs: Array = root.get("packs", [])
            if packs.size() != 20: failures.append("packs array must contain 20")
            var ids := {}
            var levels := {"L1":0,"L2":0,"L3":0,"L4":0,"L5":0}
            var total := 0
            for pack in packs:
                var id := str(pack.get("game_pack_id", ""))
                if ids.has(id): failures.append("duplicate pack: " + id)
                ids[id] = true
                var level := str(pack.get("l_level", ""))
                if levels.has(level): levels[level] += 1
                else: failures.append("invalid level: " + level)
                var opportunities: Array = pack.get("opportunities", [])
                if opportunities.size() != 6: failures.append(id + " must contain 6 opportunities")
                total += opportunities.size()
                for index in opportunities.size():
                    var expected := "%s-R%02d" % [id, index + 1]
                    if opportunities[index].get("opportunity_id") != expected: failures.append("opportunity id mismatch: " + expected)
                    if str(opportunities[index].get("frozen_content", "")).is_empty(): failures.append("empty frozen content: " + expected)
            if total != 120: failures.append("actual opportunity total must be 120")
            for level in levels:
                if levels[level] != 4: failures.append(level + " must contain 4 packs")
    if failures.is_empty():
        print("PROJECT_BASELINE_TEST_PASS")
        quit(0)
    for failure in failures: push_error(failure)
    quit(1)
