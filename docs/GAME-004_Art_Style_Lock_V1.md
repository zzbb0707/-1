# GAME-004 美术风格锁定单 V1

状态：`APPROVED_DIRECTION`
确认：用户认可 `artifacts/GAME004_art_direction_board_v001.png` 的整体风格，后续延续该方向。

## 不可改变的风格锚点

- 暖米白生态舱外壳 + 鼠尾草绿/青绿色生态层；
- 圆润玩具化3D，动画电影质感，柔和漫射光；
- 儿童友好、低攻击性、无惊吓、无尖锐危险造型；
- 正面微俯视竖屏构图；
- 规则和目标清晰优先于装饰；
- 区域使用材质/形态/颜色区分，但不依赖长文字；
- 成功反馈使用区域自然变化，不使用统一烟花；
- L1到L5是同一座生态舱的连续成长，不是五套割裂画风。

## 允许的变化

- 根据冻结回合语义替换目标对象、干扰对象和区域；
- L1–L4增加规则复杂度和区域状态；
- L5在权利通过后加入授权真实照片，但照片要嵌入同一生态舱交互框架；
- 低感官版减少装饰密度、运动、闪烁和音效，不改变语义层。

## 禁止的变化

- 改成写实摄影、扁平卡通、赛博机械或高饱和刺激风格；
- 用AI整屏图直接定义热区或规则；
- 用文字/颜色单独承担本应由形态和概念承担的分类；
- 生成没有来源和rights_status的L5照片；
- 为了“创新”加入速度、复杂手势、微小目标或惩罚反馈。

## 资产生成固定提示前缀

```text
GAME-004 approved art direction: warm ivory and sage-green habitat pod, rounded toy-like 3D animated-film render, soft diffuse lighting, gentle child-friendly forms, portrait mobile training-game composition, clear semantic silhouette, no text, no pseudo-UI, no watermark, no scary or sharp harmful details.
```

该锁定单只锁美术语言，不改变 `PROJECT_BASELINE.md` 中任何玩法、回合、规则或数量事实。

## 生产模型锁定（2026-08，用户肉眼确认）

- 唯一正式素材生产模型：`openai/gpt-image-2/text-to-image`（Atlas 中转站，$0.009/张，png，high quality）。
- 原因：最初探索版（用户批准方向）由 Codex 内置 image_generation / Image 2 生成；GPT Image 2 是同源模型链，绿色色相、哑光材质、光泽与探索版对齐，已通过用户肉眼对比确认（`handoff/visual_review_batch02_stylecheck/`）。
- Nano Banana Pro / Seedream / Qwen 生成的批次仅保留为对照或废弃参考，**不进入正式素材库**。
- 所有正式素材继续遵循 `candidate → processed → approved`，无自动批准；L5 照片 rights_status 保持 unknown 直至授权。

## 生态绿色色板锚点（2026-08 取色锁定）

从用户批准的探索版素材（水域、水生种子荚）像素取色，作为所有素材生成的绿色色值锚点，禁止再依赖 "sage-green" 等含糊文字：

- 鲜活黄绿 `#688800`
- 草绿 `#98B848`
- 鼠尾草绿 `#60A068`
- 深青绿 `#287060`
- 青绿辅助 `#307868`

生成提示词必须包含：`habitat greens following this exact palette: #688800, #98B848, #60A068, #287060, #307868`，替代笼统的 "sage-green" 描述。
