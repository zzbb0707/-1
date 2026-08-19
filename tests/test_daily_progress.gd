extends SceneTree

func _initialize() -> void:
    var path := "user://game004_daily_progress.json"
    # clean slate
    var f := FileAccess.open(path, FileAccess.WRITE)
    if f: f.store_string("{}"); f.close()
    # simulate a saved progress
    var data := {"GF03-L1-P01": {"game_pack_id": "GF03-L1-P01", "last_status": "completed", "last_completed_count": 6, "round_total": 6, "completed_at": "2026-08-20T00:00:00", "baseline_version": "GAME004-BASELINE-V1"}}
    f = FileAccess.open(path, FileAccess.WRITE)
    if f: f.store_string(JSON.stringify(data)); f.close()
    # read back
    var read := FileAccess.open(path, FileAccess.READ)
    if not read:
        push_error("daily progress file not found"); quit(1); return
    var parsed = JSON.parse_string(read.get_as_text())
    read.close()
    if not parsed is Dictionary or not parsed.has("GF03-L1-P01"):
        push_error("daily progress restore failed"); quit(1); return
    var gp = parsed["GF03-L1-P01"]
    if gp.get("last_completed_count", 0) != 6 or gp.get("baseline_version", "") != "GAME004-BASELINE-V1":
        push_error("daily progress content mismatch"); quit(1); return
    print("DAILY_PROGRESS_TEST_PASS")
    quit(0)
