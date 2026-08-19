# GAME-004｜App 联调交付包 V1

## 接入入口

App 在启动游戏前写入 `user://launch_context.json`，或在宿主层映射等价的启动上下文。游戏读取后保留未知字段，不据此推断诊断、掌握度、治疗结果或现实迁移能力。

最小字段：

```json
{
  "schema_version": "game-bridge-v1",
  "task_id": "GAME-004",
  "game_config_id": "GAMECFG-GAME-004-SLICE-L1",
  "task_session_id": "app-session-001",
  "game_session_id": "game-session-001",
  "content_version": "GAME-004-V2",
  "ruleset_version": "GAME004-SLICE-V1",
  "low_sensory": false,
  "launch_mode": "app"
}
```

也可使用启动参数：

```text
--slice=L1|L3|L4
--low-sensory
```

## 输出

当前预览实现写入：

```text
user://game004_events.ndjson
```

App 集成时应将每行作为事件转发到宿主记录通道，保持字段和事件顺序，不修改 payload 语义。

允许事件：

```text
game_start
opportunity_presented
first_response
attempt
success
error
hint_shown
game_quit
game_result
game_complete
safe_exit
```

每个事件包含：`schema_version`、`event_id`、`event_type`、`occurred_at`、`task_id`、`game_config_id`、`task_session_id`、`game_session_id`、`content_version`、`ruleset_version`、`payload`。

## 结果边界

`game_result` 只描述本次游戏内行为，例如回合数、尝试次数、错误次数、提示次数、完成状态和退出状态。不得转换为诊断、能力等级、治疗效果或现实生活表现结论。

## 联调验收

- [ ] App 能注入最小上下文。
- [ ] L1/L3/L4 能按配置启动。
- [ ] 低感官上下文和 `--low-sensory` 均生效。
- [ ] 事件可完整转发且顺序不变。
- [ ] 正常完成产生 `game_complete` 与 `game_result`。
- [ ] 安全退出产生 `safe_exit` 与 `game_result`。
- [ ] App 断开时不会阻塞或丢失游戏内安全退出。
- [ ] 真实设备与容器尺寸通过截图验收。

## 当前未验证

真实 App 传输、真实设备、真实儿童试玩尚未提供证据，以上复选项不能标记完成。
