# 云小星 GAME-004 星图生态舱

Godot `4.7.1` 原型工程。当前版本是 **L1 / 三回合可玩原型**，用于验证 GAME-004 的核心交互与 App 接口边界，不是 120 个正式内容包的最终生产版本。

## 运行

1. 用 Godot 4.7.1 导入本目录。
2. 运行主场景 `scenes/main.tscn`。
3. 用鼠标或触控操作中央对象：
   - 拖到“水池”或“阳光花圃”；
   - 或点击对象，再点击目标区域。
4. 点击“提示”测试提示事件；点击“退出”或按 `Esc` 测试主动退出。

## 当前内容

- 回合1：水生种子 → 水池
- 回合2：向阳种子 → 阳光花圃
- 回合3：更换实例，验证位置不应成为唯一线索
- 正确：区域产生专属生态反馈
- 错误：中性恢复、提示、允许重试
- 本地事件日志：`user://game004_events.ndjson`

## App 接入

首版接口契约见：`docs/GAME-004_AppBridge_Contract_V0.md`。

正式宿主可在启动时提供 `user://launch_context.json`，游戏将合并以下字段：

- `task_id`
- `game_config_id`
- `task_session_id`
- `child_profile_id`
- `daily_plan_id`
- `debug`
- `low_sensory`
- `content_version`
- `ruleset_version`

当前工程使用本地日志模拟 Bridge；真正接入 App 时由工程师替换适配层，不改 GAME-004 核心玩法。

## 重要边界

- 不把游戏正确率直接解释为能力掌握或生活泛化。
- 不把退出、停止或压力事件伪装成完成。
- 当前三回合是验证版；正式日包仍需按新版规格设计为固定六回合并通过产品、医学、游戏性和工程门禁。
