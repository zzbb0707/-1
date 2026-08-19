# GAME-004 素材资产命名规范 V1

## 规则

- 每张素材 = 一个唯一 asset_id。
- asset_id 格式：`AS-GAME004-{KIND}-{语义标识}-V001`
  - KIND：`OBJECT` / `REGION` / `OUTCOME` / `LOWSENSORY` / `RULE` / `L5`
  - 语义标识：拼音或英文短标识，禁止使用不透明编号
- 文件命名：`{语义标识}_v001.png`
- 输出目录：
  - `assets/candidates/banana/{game_pack_id}/`（候选）
  - `assets/processed/{game_pack_id}/`（处理后可加载）
  - `assets/approved/{game_pack_id}/`（人工+权益审核通过）
- manifest 必须记录：asset_id / file / source_model / prediction_id / review / rights_status / status / game_pack_ids

## 示例

- 对象"鱼"：`AS-GAME004-OBJECT-FISH-V001` → `fish_v001.png`
- 区域"水区"：`AS-GAME004-REGION-WATERZONE-V001` → `waterzone_v001.png`
- 结果"发芽"：`AS-GAME004-OUTCOME-SPROUT-V001` → `sprout_v001.png`

## 状态流转

`pending → candidate → processed → approved`，无自动批准。
`rejected` 用于审核不通过且不重做的素材。
L5 照片：`rights_status=unknown` 时不得进入 approved。
