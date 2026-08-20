# GAME-004 星图生态舱 — 运行说明（Habitat 精品场景）

## 正确启动方式（关键！）

旧 main.tscn 会拦截 `--game-pack`，必须用 `--scene` 指定 habitat 场景：

```bash
# 启动指定包（精品场景）
Godot_v4.7.1-stable_win64.exe --path D:\deepseek\yunxiaoxing-game004 \
  --scene res://scenes/habitat_slice.tscn -- --game-pack=GF03-L1-P03

# 低感官模式
... --scene res://scenes/habitat_slice.tscn -- --game-pack=GF03-L1-P03 --low-sensory

# 无头验证（CI/自动化）
... --headless --scene res://scenes/habitat_slice.tscn --quit-after 5 -- --game-pack=GF03-L1-P03
```

## 20 个包 ID

GF03-L1-P01 ~ GF03-L1-P04 / GF03-L2-P01 ~ P04 / GF03-L3-P01 ~ P04 / GF03-L4-P01 ~ P04 / GF03-L5-P01 ~ P04

## 场景结构

```
habitat_slice.tscn (Node2D)
├── habitat_game.gd   （主控：配置加载/回合/事件桥/低感官）
│   ├── 背景层（暖米白 + 柔光）
│   ├── 区域层（左/右槽位：生态素材或简洁槽）
│   ├── 对象层（透明抠图对象 + 拖拽）
│   ├── 特效层（CPUParticles2D 发光/火花）
│   └── UI层（标题/回合/提示/退出/消息）
```

## 素材

- 对象透明抠图：`assets/processed/cutout_v001/*_alpha.png`（运行时优先加载）
- 区域素材：`assets/candidates/banana/approved_candidate/region_*`
- 配置：`configs/gp/GF03-Lx-Pxx.json`

## 测试

- `tests/test_gp_configs.gd` 等 12 项原测试
- `tools/verify_l1_habitat.ps1` L1 四包 habitat 加载验证
