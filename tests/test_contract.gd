extends SceneTree

func _initialize() -> void:
    var failures: Array[String] = []
    _test_game_config(failures)
    _test_bridge(failures)
    if failures.is_empty():
        print("CONTRACT_TEST_PASS")
        quit(0)
    for failure in failures:
        push_error(failure)
    quit(1)

func _test_game_config(failures: Array[String]) -> void:
    var file := FileAccess.open("res://configs/game004_l1_p01.json", FileAccess.READ)
    if not file:
        failures.append("game config missing")
        return
    var config = JSON.parse_string(file.get_as_text())
    if not config is Dictionary:
        failures.append("game config is not valid JSON object")
        return
    for key in ["game_config_id", "task_id", "presentation_contract", "rounds", "record_fields"]:
        if not config.has(key):
            failures.append("game config missing key: " + key)
    var rounds: Array = config.get("rounds", [])
    if rounds.size() != int(config.get("round_count", -1)):
        failures.append("round_count does not match rounds length")
    var ids := {}
    for round_data in rounds:
        for key in ["opportunity_id", "object", "kind", "correct_region", "object_color"]:
            if not round_data.has(key):
                failures.append("round missing key: " + key)
        var opportunity_id := str(round_data.get("opportunity_id", ""))
        if ids.has(opportunity_id):
            failures.append("duplicate opportunity_id: " + opportunity_id)
        ids[opportunity_id] = true
    var record_fields: Array = config.get("record_fields", [])
    for field in ["game_session_id", "task_id", "attempt_count", "error_count", "hint_count", "auto_success_rate", "quit_before_finish", "stop_used"]:
        if not record_fields.has(field):
            failures.append("record_fields missing: " + field)

func _test_bridge(failures: Array[String]) -> void:
    var BridgeScript: Script = load("res://scripts/app_bridge.gd")
    var bridge: RefCounted = BridgeScript.new()
    var context: Dictionary = bridge.load_context({"task_id": "GAME-004", "game_config_id": "TEST-CONFIG", "task_session_id": "TEST-SESSION"})
    if context.get("task_id") != "GAME-004":
        failures.append("bridge context merge failed")
    var event: Dictionary = bridge.emit_event("contract_test", {"value": 1})
    for key in ["event_id", "event_type", "occurred_at", "task_id", "game_config_id", "task_session_id", "game_session_id", "payload"]:
        if not event.has(key):
            failures.append("bridge event missing key: " + key)
    var result: Dictionary = bridge.build_result("completed", {"attempt_count": 3})
    if result.get("session_status") != "completed" or result.get("attempt_count") != 3:
        failures.append("bridge result mapping failed")
