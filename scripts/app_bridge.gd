class_name AppBridge
extends RefCounted

const SCHEMA_VERSION := "game-bridge-v1"
const REQUIRED_CONTEXT_FIELDS := ["task_id", "game_config_id", "task_session_id", "content_version", "ruleset_version"]
const REQUIRED_EVENT_TYPES := ["game_start", "opportunity_presented", "first_response", "attempt", "success", "error", "hint_shown", "game_quit", "game_result", "game_complete", "safe_exit"]

var context: Dictionary = {}
var events: Array[Dictionary] = []
var game_session_id := "game-session-preview"

func load_context(default_context: Dictionary) -> Dictionary:
    context = default_context.duplicate(true)
    var file := FileAccess.open("user://launch_context.json", FileAccess.READ)
    if file:
        var parsed = JSON.parse_string(file.get_as_text())
        if parsed is Dictionary and parsed.has("task_id"):
            context.merge(parsed, true)
    game_session_id = str(context.get("game_session_id", "game-session-preview"))
    return context

func emit_event(event_type: String, payload: Dictionary) -> Dictionary:
    if not REQUIRED_EVENT_TYPES.has(event_type):
        push_warning("Unknown GAME-004 bridge event: " + event_type)
    var event := {
        "event_id": "%s-%d" % [event_type, Time.get_ticks_usec()],
        "event_type": event_type,
        "occurred_at": Time.get_datetime_string_from_system(true),
        "task_id": context.get("task_id", "GAME-004"),
        "game_config_id": context.get("game_config_id", "GAMECFG-GAME-004-GF03-L1-P01"),
        "task_session_id": context.get("task_session_id", "preview-session"),
        "game_session_id": game_session_id,
        "content_version": context.get("content_version", "GAME-004-V1"),
        "ruleset_version": context.get("ruleset_version", "ALLOC-CORE-V1"),
        "schema_version": SCHEMA_VERSION,
        "payload": payload
    }
    events.append(event)
    # 确保文件存在（READ_WRITE 不会创建文件）
    var path := "user://game004_events.ndjson"
    if not FileAccess.file_exists(path):
        var f0 := FileAccess.open(path, FileAccess.WRITE)
        if f0: f0.close()
    var file := FileAccess.open(path, FileAccess.READ_WRITE)
    if file:
        file.seek_end()
        file.store_line(JSON.stringify(event))
        file.close()
    return event

func build_result(session_status: String, summary: Dictionary) -> Dictionary:
    var result := summary.duplicate(true)
    result["schema_version"] = SCHEMA_VERSION
    result["event_type"] = "game_result"
    result["session_status"] = session_status
    result["task_id"] = context.get("task_id", "GAME-004")
    result["game_config_id"] = context.get("game_config_id", "GAMECFG-GAME-004-GF03-L1-P01")
    result["task_session_id"] = context.get("task_session_id", "preview-session")
    result["game_session_id"] = game_session_id
    return result
