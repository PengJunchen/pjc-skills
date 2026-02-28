# pjc-skills 安装文档

## 问题说明

之前，pjcskills 项目被下载到 workspace 目录下，但没有正确安装到 OpenClaw 的 skills 目录（`/app/skills`）。这意味着技能不会被 OpenClaw 自动识别和使用。

## 修复方案

### 1. 正确的 skills 目录位置

- **错误位置：** `~/.openclaw/workspace/pjc-skills/skills/`
- **正确位置：** `/app/skills/`

OpenClaw 只会从 `/app/skills/` 目录加载技能。

### 2. 修复步骤

#### 步骤 1：手动安装 clash-skill（已完成）

```bash
# 将 clash-skill 复制到正确位置
cp -r ~/.openclaw/workspace/pjc-skills/skills/clash-skill /app/skills/

# 验证安装
ls -la /app/skills/clash-skill/SKILL.md
```

#### 步骤 2：使用安装脚本（推荐）

项目提供了新的安装脚本，可以自动安装所有 skills：

```bash
# 进入项目目录
cd ~/.openclaw/workspace/pjc-skills

# 运行安装脚本
bash install-to-openclaw.sh
```

这个脚本会：
- 检查 OpenClaw skills 目录
- 将项目中的所有 skills 复制到 `/app/skills/`
- 备份已存在的 skills（如果有）
- 验证 SKILL.md 文件的存在

### 3. 目录结构

修复后的目录结构：

```
/home/node/.openclaw/workspace/
├── pjc-skills/                    # pjc-skills 项目
│   ├── skills/                    # 项目技能源码
│   │   └── clash-skill/
│   │       ├── SKILL.md
│   │       ├── README.md
│   │       ├── scripts/
│   │       ├── config/
│   │       └── docs/
│   ├── install.sh                 # 原始安装脚本（用于初始化）
│   └── install-to-openclaw.sh     # 新：OpenClaw skills 安装脚本
│
/app/skills/                       # OpenClaw skills 目录（实际使用位置）
└── clash-skill/                   # 已安装的技能（通过脚本复制）
    ├── SKILL.md
    ├── README.md
    ├── scripts/
    ├── config/
    └── docs/
```

### 4. 安装说明

#### 原始安装脚本（install.sh）

`install.sh` 是原始的安装脚本，用于：
- 检测 OpenClaw 环境
- 初始化 clash-skill
- 创建 BOOT.md 配置文件
- 提供使用指南

**重要：** 这个脚本**不会**将 skills 安装到 `/app/skills/`。

#### 新安装脚本（install-to-openclaw.sh）

`install-to-openclaw.sh` 是专门为 OpenClaw 设计的安装脚本，用于：
- 将项目中的 skills 复制到 `/app/skills/`
- 备份已存在的 skills
- 验证安装

### 5. 使用流程

#### 首次安装

```bash
# 1. 下载或克隆 pjc-skills 项目到 workspace
cd ~/.openclaw/workspace
git clone <repository-url> pjc-skills

# 2. 运行 OpenClaw skills 安装脚本
cd pjc-skills
bash install-to-openclaw.sh

# 3. 运行原始安装脚本（用于初始化）
bash install.sh
```

#### 后续更新

```bash
# 1. 更新项目代码
cd ~/.openclaw/workspace/pjc-skills
git pull

# 2. 重新安装 skills
bash install-to-openclaw.sh
```

### 6. 验证安装

#### 方法 1：检查技能文件

```bash
ls -la /app/skills/clash-skill/SKILL.md
```

#### 方法 2：查看 OpenClaw 技能列表

OpenClaw 应该能自动识别并显示 clash-skill。

### 7. 技能使用

一旦技能正确安装在 `/app/skills/`，OpenClaw 会：

1. 自动加载技能描述（从 SKILL.md）
2. 根据你的请求识别何时使用该技能
3. 自动读取 SKILL.md 并执行相应操作

### 8. 故障排除

#### 技能未被识别

确保：
- [ ] SKILL.md 文件存在于 `/app/skills/clash-skill/`
- [ ] SKILL.md 包含有效的技能格式
- [ ] OpenClaw 会话已重新加载（如果需要）

#### 文件权限问题

```bash
# 确保 OpenClaw 有读取权限
chmod -R 755 /app/skills/clash-skill
```

#### 手动测试技能

```bash
# 查看 SKILL.md
cat /app/skills/clash-skill/SKILL.md

# 测试技能脚本
bash /app/skills/clash-skill/scripts/clash.sh status
```

## 修复日期

2026-02-28 06:18 UTC

## 更新记录

- ✅ 创建了 `install-to-openclaw.sh` 脚本
- ✅ 将 clash-skill 正式安装到 `/app/skills/`
- ✅ 清理 workspace 目录，移除重复项目
- ✅ 创建安装文档
