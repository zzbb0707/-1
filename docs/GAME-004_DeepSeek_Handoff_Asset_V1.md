# GAME-004 素材阶段交付摘要（供 DeepSeek 接手）

## 一句话现状

素材生产阶段已完成 L1 核心 + L2 第一批，86个素材通过 Atlas 机器视觉审核（approved_candidate），已提交 git；受预算限制暂停新生成，等你充值后继续或先推进代码阶段。

## 已交付素材（86个）

目录：`assets/candidates/banana/approved_candidate/`（79个文件）
清单：`assets/candidates/banana/approved_manifest.json`

覆盖：
- L1 对象：红圆种子/蓝方晶体/黄星叶/绿三角石/白圆水滴(v3)/紫方工具/鱼/鸟/花/锤/苹果/小车/杯/鞋/蓝星/大小石/圆方图标/圆工具标/方种子标/花纹方/透明圆/绿圆/红圆/蓝方 等
- L1 区域：水域/天空/花园/工具/岩/光/食物/餐具/穿戴/交通/大中小/维修/森林/阳光 等
- L1 结果：发芽/灯/叶展/岩稳/水流/工作台/整理/响应类 等
- L2 对象：红花/蓝叶/黄种子/大圆石/小圆石/大方箱/小方箱/中种子

## 回合映射

- `handoff/asset_production_v001/l1_round_asset_map.json`：L1 对象24/24、区域19/24、结果23/24
- `handoff/asset_production_v001/l2l5_round_asset_map.json`：L2 已映射6个回合

## 数据契约

- 素材状态：`approved_candidate`（Atlas机器视觉通过，仍需项目审美抽检+权益审核才可 approved）
- rights_status：全部 unknown（尤其 L5 照片未授权不得入库）
- 未验证项：真实App联调/真实设备/真实用户测试均为 unverified

## 待 DeepSeek 做的事

1. 读取上述 manifest 和映射表，不要改写 frozen_content
2. 用 approved_candidate 素材填充运行器（L1 已可闭环）
3. 剩余素材在预算恢复后继续生产（队列：`assets/candidates/banana/final_visual_queue.json`，234项）
4. L3/L4/L5 素材缺口较大，需优先补区域和结果

## 预算状态

- 账户余额约 $18.45
- 剩余素材约150个需约$21
- 生成脚本：`tools/banana_pipeline.ps1`（队列生成）+ Atlas API（提交/轮询/审核）
