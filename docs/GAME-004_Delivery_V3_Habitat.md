# GAME-004《星图生态舱》交付报告 V3（Habitat 精品场景）

## 交付状态：精品场景可玩（L1 四包验证通过，20包可加载）

基于已冻结的 PROJECT_BASELINE.md 与 baseline/game004_content_baseline.json。

## 1. 精品场景（habitat_slice.tscn）

按 Godot 4 最佳实践重构的正式游戏场景，替代旧 `_draw()` 灰盒：

| 能力 | 状态 |
|---|---|
| 场景系统（Sprite2D/Node2D/Control） | ✅ |
| Tween 拖拽（拾取放大/回弹/飞入） | ✅ |
| CPUParticles2D 自然反馈（发光/火花/庆祝） | ✅ |
| 配置驱动 20 包（--game-pack） | ✅ 20/20 加载 |
| 透明抠图对象（裁边+alpha） | ✅ 113+/136 |
| 区域生态素材匹配 | ✅ 58/95 区域 |
| UI（标题/回合/提示/退出/消息） | ✅ |
| 事件桥（game-bridge-v1 全事件） | ✅ |
| 低感官模式 | ✅ |
| 提示系统（规则+特征+干扰提示） | ✅ |
| 安全退出 | ✅ |

## 2. L1 四包 habitat 验证

- GF03-L1-P01：✅ 红圆种子→同图红圆区，polish 8
- GF03-L1-P02：✅ 鸟→水区/陆区，polish 7
- GF03-L1-P03：✅ 蓝方→方区，polish 8
- GF03-L1-P04：✅ 当前目标图→同图区域，polish 6
- 20包 headless 加载：✅ 20/20

## 3. 启动方式（重要）

```bash
Godot_v4.7.1-stable_win64.exe --path <proj> \
  --scene res://scenes/habitat_slice.tscn -- --game-pack=GF03-L1-P03
```

必须用 `--scene`（旧 main.tscn 会拦截 --game-pack）。

## 4. 素材完成度

- 120回合 × 3层 = 360绑定：309/360（86%），真实缺口 = 0
- 对象透明抠图：113/136（后台补齐中）
- approved_candidate：约230文件

## 5. 未验证/已知问题（如实标注）

- 真实云小星 App 宿主联调：**unverified**
- 真实设备视觉验收：**unverified**
- 真实儿童/用户测试：**unverified**
- 部分对象素材审美待定（红圆种子像草莓等）——素材可替换，不影响架构
- L5 授权照片：无授权，未入库
- 音频：待用户提供

## 6. 文档索引

- 运行指南：docs/GAME-004_Run_Guide_Habitat_V1.md
- Godot 技能手册：docs/GAME-004_Godot_Playbook_V1.md
- 原测试：tests/（12项）+ tools/verify_l1_habitat.ps1
