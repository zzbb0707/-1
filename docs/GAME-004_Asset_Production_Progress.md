# GAME-004 素材生产进度记录

## 状态：进行中（素材阶段）

目标：用统一 Banana 风格把 20 个固定游戏日包所需素材做齐，形成可交给 DeepSeek 继续代码的素材交付包。

## 已完成

- **素材批量生产进行中**：Banana 单对象模式，已覆盖 L1 完整 + L2-L4 大量对象/区域/结果。
  - 累计 approved_candidate：155+（第十批生成中）
  - approved_candidate 目录：151个文件（对象95 / 区域25 / 结果31）
  - 已推送 git：26f90e9 / a0bf748 / a650965
- Banana 风格母版：`assets/candidates/banana/master/L1_objects_master_banana_v001.jpg`（Atlas 审核 PASS）
- 母版 manifest：`assets/candidates/banana/manifest.json`
- 120 回合交付清单：`handoff/asset_production_v001/delivery_checklist.json`
- L1 回合映射表：`handoff/asset_production_v001/l1_round_asset_map.json`
- L2–L5 回合映射表：`handoff/asset_production_v001/l2l5_round_asset_map.json`
- 20 包批量规格：`handoff/asset_production_v001/20pack_batch_spec.json`
- 批量队列：`assets/candidates/banana/submission_queue.json`（360项，$50.4）
- 去重队列：`assets/candidates/banana/dedup_queue.json`（259项，$36.26）
- 批量流水线脚本：`tools/banana_pipeline.ps1`
- 视觉审核门禁文档：`docs/GAME-004_Atlas_Vision_Gate_V1.md`

## 进行中

- **生成策略调整（重要）**：Nano Banana 对"3x2接触表/6个"结构指令遵守不稳定（对象B、区域瓦片均生成了9个，FAIL；但画面质量本身合格）。已改用**单对象生成模式**（每张图一个对象/区域/结果，模型对"exactly one"遵守稳定，鱼对象已成功）。
  - 单对象验证中：杯子 `9329a9668bf44dd285db020a2ec7802d`、水域瓦片 `c6fcbc455dcb4072a48f4849792571a5`
- L1 首批接触表（旧策略，结果参考）：
  - 对象A：`12d904baf88d4e84855340889c213a65`（曾卡顿）
  - 对象B：`dd8cfdfcca8d4597af646448d0149567`（FAIL，9个对象）
  - 区域：`c9c2d7a1f6744d11ac4005274366b4ef`（FAIL，9个瓦片）
  - 鱼单对象：`e5f7d1fae5fc48ff9ff648477637460e`（completed，成功样例）

## 待做

- 等待/重试 L1 首批素材
- 批量生成 259 个唯一素材
- 逐批 Atlas 视觉审核
- 拆分、抠图、命名
- 整理素材交付包
- 标记所有未验证项

## 预算

- 去重后估算：$36.26
- 当前账户可用：$31.71，冻结 $0.42
