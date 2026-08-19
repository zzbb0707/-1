extends SceneTree

func _initialize() -> void:
    var failures: Array[String] = []
    var dir := DirAccess.open("res://configs/gp")
    var total := 0
    dir.list_dir_begin()
    var filename := dir.get_next()
    while filename != "":
        if filename.ends_with(".json"):
            var file := FileAccess.open("res://configs/gp/" + filename, FileAccess.READ)
            var config = JSON.parse_string(file.get_as_text()) if file else null
            if config is Dictionary:
                for round_data in config.get("rounds", []):
                    total += 1
                    if round_data.get("implementation_status") != "semantic_defined_needs_art":
                        failures.append(str(round_data.get("opportunity_id", filename)) + " invalid semantic status")
                    if str(round_data.get("target_display_name", "")).is_empty(): failures.append("missing target")
                    if str(round_data.get("correct_region_label", "")).is_empty(): failures.append("missing region")
                    if str(round_data.get("rule_id", "")).is_empty(): failures.append("missing rule")
                    if str(round_data.get("natural_outcome_label", "")).is_empty(): failures.append("missing outcome")
                    var region_set: Array = round_data.get("region_set", [])
                    if region_set.size() < 2 or region_set.size() > 4: failures.append("region count invalid")
        filename = dir.get_next()
    dir.list_dir_end()
    if total != 120: failures.append("expected 120 semantic rounds")
    if failures.is_empty():
        print("GP_SEMANTICS_TEST_PASS")
        quit(0)
    for failure in failures: push_error(failure)
    quit(1)
