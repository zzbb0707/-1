# GAME-004 Atlas视觉审核门禁 V1

## 目的

当主对话模型不具备图像输入时，使用 Atlas `atlas_upload_media` + `atlas_see` 作为机器视觉审核链。该链只提供视觉证据，不自动把素材升级为 approved。

## 固定流程

1. 生成结果下载到 `assets/candidates/`。
2. 使用 `atlas_upload_media` 上传临时审核副本。
3. 使用 `atlas_see` 询问结构、语义、风格、儿童安全和低感官要求。
4. 将回答、模型、时间、源文件、prediction_id 写入该批次 manifest。
5. PASS 只能进入 `processed_candidate`，还需要项目审美抽检和权益记录才能进入 `approved`。
6. FAIL 进入 `rejected` 或 `needs_revision`，不得绑定正式运行时。

## 每张接触表的必问项

- 数量是否正确；
- 单元是否清晰分离、无重叠、无裁切；
- 无文字、无水印、无伪UI；
- 目标语义是否正确；
- 与统一Banana风格参考的色相、光泽、粗糙度、阴影和细节密度是否一致；
- 是否有尖锐、惊吓、攻击性或儿童不适元素；
- 是否适合拆分为独立运行时资产。

## 结论规则

- 任一硬门失败：`FAIL`；
- 视觉模型意见冲突：`needs_human_review`；
- 机器PASS不等于最终批准；
- `rights_status=unknown` 的资产不得标记 `approved`；
- L5真实照片没有授权材料时保持 `inactive`。

## 未验证项

Atlas机器视觉不能替代真实设备视觉验收、真实App宿主联调或真实儿童/用户测试。以上三项在没有证据时必须保持 `unverified`。
