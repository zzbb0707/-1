# GAME-004 测试矩阵 V1

基线版本：GAME004-BASELINE-V1
运行环境：Godot 4.7.1 headless，Windows
状态：全量回归通过（12/12 PASS）

## 测试清单

| 测试 | 内容 | 结果 |
|---|---|---|
| test_project_baseline | 冻结基线数量/哈希/父映射 | PASS |
| test_contract | 数据契约 | PASS |
| test_bridge_schema | Game Bridge 事件/上下文 schema | PASS |
| test_slice_configs | 旧切片配置兼容 | PASS |
| test_processed_assets | 早期处理素材存在 | PASS |
| test_asset_candidates | 候选素材存在 | PASS |
| test_gp_configs | 20包×6回合配置完整性 | PASS |
| test_gp_semantics | 120回合语义字段/状态 | PASS |
| test_l1p01_object_assets | L1P01对象素材绑定 | PASS |
| test_l1p01_region_assets | L1P01区域素材绑定 | PASS |
| test_daily_progress | 跨日进度保存/恢复 | PASS |
| test_per_pack_automation | 逐包自动化（120回合/低感官/资产覆盖） | PASS |

## 覆盖率结论

- 120回合语义：100%
- 低感官标记：20/20
- L1素材绑定：4/4包（P01-P04）
- L2-L5素材绑定：0/16（预算未恢复，待补）

## 未验证项（明确标注）

- 真实 App 宿主联调：unverified
- 真实设备视觉验收：unverified
- 真实儿童/用户测试：unverified
- L5授权照片：无授权，未入库
