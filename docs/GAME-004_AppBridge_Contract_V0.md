# GAME-004 星图生态舱｜App Bridge 与游戏交付契约 V0

> 状态：首版实现契约；基于旧交接包的会话、事件与记录要求整理。具体游戏内容以新版 `GF-03 / GAME-004` 规格为准。工程师接入 App 前须将本契约与真实宿主接口联调确认。

## 1. 交付边界

- 游戏：Godot 4.7.1，2D 竖屏优先的独立游戏包。
- 宿主 App：负责鉴权、今日任务分配、创建/持久化训练会话、展示家长端记录和报告。
- 游戏：不直接请求儿童档案、计划或报告 API；只接收受控启动配置，并向宿主发出结构化事件和结束结果。
- 本游戏不能以单局结果声明能力提升、诊断结论或泛化结果。

## 2. 启动配置

宿主在启动前向游戏注入 JSON。首版支持本地 `user://launch_context.json`；正式接入可替换为平台 Bridge，不改玩法层。

```json
{
  "schema_version": "game-bridge-v0",
  "task_id": "GAME-004",
  "game_config_id": "GAMECFG-GAME-004-GF03-L1-P01",
  "task_session_id": "ts_example",
  "child_profile_id": "child_example",
  "daily_plan_id": "plan_example",
  "debug": false,
  "low_sensory": false,
  "launch_mode": "assigned",
  "content_version": "GAME-004-V1",
  "ruleset_version": "ALLOC-CORE-V1",
  "presentation_contract": {
    "mode": "single_stage_simultaneous",
    "stable_stage": true,
    "prompt_position": "inside_stage_bottom"
  }
}
```

缺失或无效配置时，游戏以 `preview` 模式启动；预览数据仅写本地调试日志，不可上传为正式训练记录。

## 3. 宿主必须接收的基础事件

| 事件 | 时机 | 必填字段 |
|---|---|---|
| `game_start` | 游戏进入首回合 | 会话锚点、模式、回合数 |
| `opportunity_presented` | 每个训练机会呈现 | `opportunity_id`、规则、目标、干扰项 |
| `first_response` | 当局首次有效触摸 | `reaction_time_ms`、输入方式 |
| `attempt` | 每次分类落位 | 目标、选择区域、输入方式 |
| `success` | 当前机会正确完成 | 提示等级、耗时、是否首次正确 |
| `error` | 当前机会错误落位 | 错误类型、提示等级 |
| `hint_shown` | 提示升级 | 提示等级、原因 |
| `game_quit` | 用户主动退出 | 当前回合、已完成数 |
| `safe_exit` | 压力/安全停止 | 停止原因 |
| `game_complete` | 固定回合完成 | 聚合指标与结果摘要 |

所有事件带有：`event_id`、`occurred_at`、`task_id`、`game_config_id`、`task_session_id`、`game_session_id`、`content_version`、`ruleset_version`。

## 4. 结束结果

游戏向宿主提交 `game_result`，由宿主映射到 `task_sessions`、`game_sessions` 和 `training_records`。建议字段：

```json
{
  "event_type": "game_result",
  "session_status": "completed",
  "completion_time_sec": 42.2,
  "attempt_count": 4,
  "error_count": 1,
  "hint_count": 1,
  "auto_success_rate": 0.75,
  "quit_before_finish": false,
  "stop_used": false,
  "downgrade_used": false,
  "safety_event": false,
  "raw_events_ref": "local://..."
}
```

## 5. GAME-004 首版玩法映射

- 主目标：根据当前规则，把对象安排到合适生态区域。
- 首版为 L1 灰盒垂直切片，固定 3 个机会；正式日包按新版规格扩为固定 6 个机会。
- 输入：拖放；点击对象后点击区域是等价输入。
- 规则：第一局高差异水生种子→水池；第二局向阳种子→阳光花圃；第三局新实例并交换左右位置。
- 错误：对象进入中性缓冲台；不显示红叉、扣分或角色失望；给出相关特征提示并允许修复。
- 完成：正确分类引起区域专属生态变化，非通用烟花。

## 6. 验收底线

- 宿主可注入启动上下文，游戏可回退预览模式。
- 退出、停止、完成均有结构化结果，且不会将退出伪装为完成。
- 所有三回合均生成机会级事件；每局的首个有效反应可计算。
- `low_sensory=true` 时关闭持续粒子与强烈环境动画。
- 游戏不包含儿童姓名、诊断、疗效承诺或未经授权的网络请求。
