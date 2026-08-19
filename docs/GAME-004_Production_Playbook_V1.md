# GAME-004｜可复用生产流程 V1

## 内容包结构

```text
configs/game004_<slice>_slice.json
assets/candidates/image2/<batch>/
assets/processed/<version>/
assets/approved/<version>/
tests/test_*.gd
tools/prepare_assets.ps1
tools/verify_vertical_slice.ps1
docs/
```

## 标准流水线

1. 设计只改变配置与规则，不直接写死关卡逻辑。
2. AI资产先入 `candidates`，生成manifest，记录模型、源文件、尺寸、hash和审核状态。
3. 运行 `tools/prepare_assets.ps1` 做黑底/alpha预处理；输出进入 `processed`，不能自动成为approved。
4. 人工/视觉审核通过后，才复制到 `approved`。
5. Godot运行器只通过资源路径和配置读取资产；交互热区由配置/代码定义，不由图片边缘定义。
6. 每次修改必须运行：工程解析、Bridge测试、slice配置测试、资产测试、L1/L3/L4实机截图。
7. 视觉门禁检查对象与选项不遮挡、文字不截断、按钮可见、低感官刺激受控。
8. App联调只接收/转发Bridge事件，不改变游戏内语义，不做诊断或现实迁移推断。

## 失败处理

- Image API连续失败：停止当前批次，切换备用API；保留已生成文件，不重复覆盖。
- alpha不合格：保留原候选，生成processed副本；不得覆盖候选源。
- 截图出现遮挡：修配置/绘制层后全套重渲染，不能只修单层。
- 测试失败：不交付试玩，不用“视觉看起来没问题”替代测试。
- 真实App或真机缺失：在交付状态中标记未验证，不得伪造联调证据。
