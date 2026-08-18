extends SceneTree

const LEVELS := ["l1", "l3", "l4"]

func _initialize() -> void:
    var failures: Array[String] = []
    var expected_regions := {"l1": 2, "l3": 3, "l4": 4}
    for level in LEVELS:
        var path := "res://configs/game004_%s_slice.json" % level
        var file := FileAccess.open(path, FileAccess.READ)
        if not file:
            failures.append("missing: " + path)
            continue
        var config = JSON.parse_string(file.get_as_text())
        if not config is Dictionary:
            failures.append("invalid JSON: " + path)
            continue
        var regions: Array = config.get("regions", [])
        var object_position: Array = config.get("object_position", [])
        if object_position.size() != 2:
            failures.append(level + " missing object_position")
        if regions.size() != expected_regions[level]:
            failures.append("%s expected %d regions, got %d" % [level, expected_regions[level], regions.size()])
        var region_names: Array[String] = []
        for region in regions:
            region_names.append(str(region.get("name", "")))
            var rect: Array = region.get("rect", [])
            if rect.size() != 4:
                failures.append(level + " invalid region rect")
            elif object_position.size() == 2:
                var object_x := float(object_position[0])
                var object_y := float(object_position[1])
                var padding_x := 0.09
                var padding_y := 0.07
                var overlaps_x: bool = object_x + padding_x > float(rect[0]) and object_x - padding_x < float(rect[0]) + float(rect[2])
                var overlaps_y: bool = object_y + padding_y > float(rect[1]) and object_y - padding_y < float(rect[1]) + float(rect[3])
                if overlaps_x and overlaps_y:
                    failures.append("%s object overlaps region %s" % [level, region.get("name", "")])
        for round_data in config.get("rounds", []):
            for key in ["opportunity_id", "object", "correct_region", "rule_id", "hint", "success_message"]:
                if not round_data.has(key): failures.append("%s round missing %s" % [level, key])
            if not region_names.has(str(round_data.get("correct_region", ""))):
                failures.append("%s correct_region not declared" % level)
        if level == "l3":
            var rule_ids := {}
            for round_data in config.rounds: rule_ids[round_data.rule_id] = true
            if rule_ids.size() < 3: failures.append("l3 must demonstrate controlled rule switching")
        if level == "l4":
            for round_data in config.rounds:
                if not round_data.has("examples") or round_data.examples.size() < 2:
                    failures.append("l4 needs two inference examples per round")
    if failures.is_empty():
        print("SLICE_CONFIG_TEST_PASS")
        quit(0)
    for failure in failures: push_error(failure)
    quit(1)
