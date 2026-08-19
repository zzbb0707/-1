# GAME-004 素材交付包结构 V1

## 目标

把已审核通过的 Banana 素材整理为 DeepSeek 可直接接手的素材交付包，用于后续运行器/测试/联调阶段。

## 目录结构

```
handoff/asset_production_v001/
├── GAME004_ASSET_MASTER_MANIFEST_V1.json    # 120回合总清单
├── GAME004_ASSET_BATCH_PLAN_V1.md           # 批次计划
├── GAME004_ASSET_HANDOFF_V1.md              # 交接说明
├── GAME004_DEEPSEEK_HANDOFF_CHECKLIST.md    # DeepSeek接手清单
├── delivery_checklist.json                  # 120回合交付清单
├── l1_round_asset_map.json                  # L1回合素材映射
├── l2l5_round_asset_map.json                # L2-L5回合素材映射
├── 20pack_batch_spec.json                   # 20包批量规格
└── batches/                                 # L1-L5批次规格
```

## 素材目录

```
assets/candidates/banana/
├── master/              # 风格母版
├── single/              # 单对象原始生成
├── approved_candidate/  # 通过Atlas审核的素材（63个）
├── batch_v2..v9_manifest.json  # 各批次生成/审核记录
├── manifest.json        # 母版记录
└── review_queue.json    # 审核队列
```

## 待补

- 第九批8个素材审核结果
- 每回合 asset_id → 文件映射（填充 l1/l2l5_round_asset_map.json 的 asset_map 字段）
- L5 授权照片（保持 inactive，无授权不入库）
- 最终打包压缩
