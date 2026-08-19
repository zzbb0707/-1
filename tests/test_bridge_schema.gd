extends SceneTree

func _initialize() -> void:
    var bridge_script: Script = load("res://scripts/app_bridge.gd")
    var bridge: RefCounted = bridge_script.new()
    var context: Dictionary = bridge.load_context({
        "task_id": "GAME-004",
        "game_config_id": "TEST",
        "task_session_id": "SESSION",
        "content_version": "V2",
        "ruleset_version": "R1"
    })
    var event: Dictionary = bridge.emit_event("game_start", {"slice_id": "L1"})
    var result: Dictionary = bridge.build_result("completed", {"completed_rounds": 2})
    var failures: Array[String] = []
    for key in ["task_id", "game_config_id", "task_session_id", "content_version", "ruleset_version"]:
        if not context.has(key): failures.append("context missing " + key)
    for key in ["schema_version", "event_id", "event_type", "occurred_at", "payload"]:
        if not event.has(key): failures.append("event missing " + key)
    if event.schema_version != "game-bridge-v1": failures.append("event schema mismatch")
    if result.schema_version != "game-bridge-v1": failures.append("result schema mismatch")
    if failures.is_empty():
        print("BRIDGE_SCHEMA_TEST_PASS")
        quit(0)
    for failure in failures: push_error(failure)
    quit(1)
