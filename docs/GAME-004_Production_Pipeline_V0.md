# GAME-004 星图生态舱｜可复用生产流程 V0

## 目的

把“做一张漂亮图、写一段玩法代码”变成可重复的训练游戏生产流程。此流程只定义游戏生产与接入，不重写新版训练目标、分配规则或医学审核规则。

## 一、输入门禁

一个游戏日包进入实现前必须具备：

1. `task_id`、`game_config_id`、`content_version`、`ruleset_version`；
2. 一个主要目标行为和明确的有效机会/不算完成；
3. 固定回合数、每回合规则、目标、干扰项和正确自然结果；
4. 提示、错误修复、退出、停止和降级规则；
5. `presentation_contract`；
6. 事件字段与报告边界；
7. 素材清单与低感官要求。

缺任一项，只能是 `draft`，不得进入正式 App 分配。

## 二、工程分层

```text
App Bridge（宿主上下文、事件、结果）
  └─ 游戏运行器（会话生命周期、提示、退出、低感官）
      └─ 游戏家族逻辑（GAME-004 分类→生态结果）
          └─ 日包配置（回合、对象、规则、区域、素材引用）
              └─ 资产清单（状态、尺寸、感官、版本、授权）
```

- 共用层不可写具体训练答案。
- 日包配置不可绕过会话与事件层。
- 资产不直接决定规则；只引用配置许可的资产。

## 三、资产入库最小字段

每个正式资产必须登记：

```json
{
  "asset_id": "AST-GAME004-...",
  "asset_type": "background | object | region | ui | sfx | video",
  "state": "idle | selectable | hint | success | low_sensory",
  "game_scene_key": "game004_star_habitat",
  "pixel_size": "width x height",
  "anchor": "center | bottom_center",
  "visual_complexity": "low | medium | high",
  "sensory_intensity": "low | medium | high",
  "license_status": "pending | approved",
  "asset_version": "V1"
}
```

AI 生成图只可标为 `candidate`，通过状态完整、透明背景/裁切、风格一致性、感官、权利和尺寸检查后才可变为 `approved`。

## 四、验证顺序

1. **配置校验：** JSON 格式、必填 ID、回合数、事件字段齐全。
2. **Godot 校验：** 项目可解析、无脚本错误、可启动。
3. **桌面试玩：** 鼠标拖放与点击选择均可完成。
4. **尺寸试玩：** 至少检查 390×844、844×390、1024×768；舞台、提示、按钮和对象不被遮挡。
5. **训练机制复核：** 随机乱点、固定位置记忆、系统代做不得算成功。
6. **App 联调：** 启动上下文、`game_start`、机会事件、结束结果、退出与停止均可被宿主接收。
7. **人工试玩：** 记录“是否理解/是否愿意继续/哪里困惑”，而不是只记录正确率。

## 五、发布状态

```text
draft → prototype → internal_review → app_integration_ready → approved → active
```

- `prototype`：仅可供内部试玩，不可作为训练证据。
- `app_integration_ready`：接口与日志验证通过，仍需内容、医学与人工审核。
- `approved`：可以进入审核后的任务库。
- `active`：才允许被 App 分配给儿童。

## 六、GAME-004 当前状态

- 当前：`prototype`
- 已有：三回合交互、两种输入、错误修复、本地事件、结果回传模拟、基础 Bridge 契约。
- 未有：正式六回合日包、正式资产、设备尺寸验收、真实宿主联调、儿童试玩、审核批准。
