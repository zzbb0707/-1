# GAME-004 基线变更与施工控制

## 每个后续任务的开头必须写

```text
baseline_version: GAME004-BASELINE-V1
game_id: GAME-004
game_pack_ids: 明确列出；共用系统写 ALL-GF03
source: PROJECT_BASELINE.md + baseline/game004_content_baseline.json
scope: code | config | art | audio | test | integration
acceptance: 引用PROJECT_BASELINE具体章节
```

没有以上头信息，不开始生成代码、配置或素材。

## 内容不可自行改动

以下内容为冻结事实：GAME/GF/TU父子关系、20个GP ID和名称、每包6机会、120条`frozen_content`、L级、正确分类语义、屏幕证据边界。工程和美术只能实现，不能改写。

若发现冻结内容无法施工、歧义或互相冲突：创建`baseline/change_requests/CR-xxxx.md`，记录来源、受影响ID、冲突、建议和风险；状态保持`proposed`，未获用户/产品/医学确认前禁止修改基线和active配置。

## 允许直接修改

不改变内容语义的实现优化，如性能、缓存、日志、编辑器工具、无障碍输入、截图测试和错误修复，可以直接施工，但必须通过基线测试和相关回归。

## 发布门禁

每次发布至少通过：

```text
PROJECT_BASELINE_TEST_PASS
CONTRACT_TEST_PASS
BRIDGE_SCHEMA_TEST_PASS
SLICE/GP CONFIG TEST PASS
ASSET MANIFEST TEST PASS
实机视觉与交互证据
```

正式20包实现后，代表slice只作开发预览，不计完成证据。
