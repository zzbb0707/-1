extends SceneTree

func _initialize() -> void:
    var failures: Array[String] = []
    var dir := DirAccess.open("res://configs/gp")
    if dir == null:
        push_error("configs/gp missing")
        quit(1)
        return
    var count := 0
    var total := 0
    dir.list_dir_begin()
    var filename := dir.get_next()
    while filename != "":
        if filename.ends_with(".json"):
            count += 1
            var file := FileAccess.open("res://configs/gp/" + filename, FileAccess.READ)
            var data = JSON.parse_string(file.get_as_text()) if file else null
            if not data is Dictionary:
                failures.append(filename + " invalid json")
            else:
                for key in ["game_pack_id", "game_id", "game_family_id", "primary_training_unit_id", "l_level", "fixed_opportunity_count", "rounds"]:
                    if not data.has(key): failures.append(filename + " missing " + key)
                var rounds: Array = data.get("rounds", [])
                if rounds.size() != 6: failures.append(filename + " must have 6 rounds")
                total += rounds.size()
                for round_data in rounds:
                    for key in ["opportunity_id", "frozen_content", "implementation_status", "data_fields", "target_display_name", "correct_region_label", "correct_region_id", "rule_id", "rule_label", "region_set", "semantic_feature", "distractor_guidance", "natural_outcome_label", "natural_outcome_id"]:
                        if not round_data.has(key): failures.append(filename + " round missing " + key)
        filename = dir.get_next()
    dir.list_dir_end()
    if count != 20: failures.append("expected 20 gp configs, got %d" % count)
    if total != 120: failures.append("expected 120 rounds, got %d" % total)
    if failures.is_empty():
        print("GP_CONFIG_TEST_PASS")
        quit(0)
    for failure in failures: push_error(failure)
    quit(1)
