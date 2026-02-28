# Clash Proxy 通用路径说明

---

## 📌 概述

本指南帮助理解 Clash-skill 如何与 OpenClaw 实现路径兼容，确保在不同安装环境下都能正常工作。

---

## 📍 OpenClaw 目录结构

OpenClaw 的典型安装目录结构：

```
~/
└── .openclaw/
    ├── openclaw.json          # OpenClaw 主配置
    ├── workspace/             # 主要工作区
    │   ├── BOOT.md            # 启动脚本（可选，由 boot-md hook 读取）
    │   ├── clash-skill/       # Clash 代理技能
    │   │   ├── SKILL.md       # 技能说明
    │   │   ├── scripts/       # 脚本目录
    │   │   │   ├── clash.sh
    │   │   │   ├── clash-monitor.sh
    │   │   │   └── proxy.sh
    │   │   └── docs/          # 文档
    │   └── ...
    ├── cron/
    │   └── jobs.json          # Cron 任务配置
    └── credentials/           # 凭证文件
```

**可能的变体：**

- **WSL2**: `/home/username/.openclaw/workspace/`
- **Linux**: `/home/username/.openclaw/workspace/`
- **系统安装**: `/opt/openclaw/workspace/`
- **自定义路径**: `/your/custom/path/workspace/`

---

## 🔍 路径检测方法

OpenClaw 会从配置文件读取工作目录，或检测当前执行上下文。

### 方法 1: 查找 clash-skill 目录

```bash
# 用户级安装
find ~ -name "clash-skill" -type d 2>/dev/null

# 系统级安装
find /opt -name "clash-skill" -type d 2>/dev/null

# 全盘搜索（较慢）
find / -name "clash-skill" -type d 2>/dev/null
```

### 方法 2: 查看配置文件

```bash
# 查看主配置
cat ~/.openclaw/openclaw.json | grep workspace

# 使用 jq 提取路径（如果已安装）
cat ~/.openclaw/openclaw.json | jq -r '.workspaceDir // .workspace // empty'
```

### 方法 3: 检查 BOOT.md 位置

BOOT.md 文件通常位于 OpenClaw workspace 的根目录，该配置文件的位置可以辅助判断安装拓扑（相对或独立）。

```bash
# 常见位置
ls -lh ~/.openclaw/workspace/BOOT.md
```

---

## 🛠️ 路径配置方式

### BOOT.md 配置

BOOT.md 中推荐三种配置方式，从简单到灵活：

#### 方式 1: 相对路径（推荐）

**适用场景**: clash-skill 是 workspace 根目录的子目录

**优点**:
- 最简单直接
- 不依赖具体路径
- 可迁移性强

**配置示例**:
```bash
# 启动 Clash
bash clash-skill/scripts/clash.sh start
```

#### 方式 2: 绝对路径（明确指定）

**适用场景**: 需要明确指定完整路径

**优点**:
- 不会产生歧义
- 适合脚本自动化

**配置示例**:
```bash
# 使用 $HOME 环境变量
CLASH_SKILL_DIR="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}/clash-skill"
bash "$CLASH_SKILL_DIR/scripts/clash.sh" start

# 或使用完整路径
bash "$HOME/.openclaw/workspace/clash-skill/scripts/clash.sh" start
```

#### 方式 3: 自动检测路径（最灵活）

**适用场景**: 不确定具体安装位置，需要自动检测

**优点**:
- 最大兼容性
- 支持多种安装场景
- 自动适应路径变更

**配置示例**:
```bash
# 自动检测并启动
if [ -f "clash-skill/scripts/clash.sh" ]; then
    # 情况 1: clash-skill 在当前目录（相对路径）
    bash clash-skill/scripts/clash.sh start
elif [ -f "$HOME/.openclaw/workspace/clash-skill/scripts/clash.sh" ]; then
    # 情况 2: 默认用户位置
    bash "$HOME/.openclaw/workspace/clash-skill/scripts/clash.sh" start
elif [ -f "/opt/openclaw/workspace/clash-skill/scripts/clash.sh" ]; then
    # 情况 3: 系统安装位置
    bash "/opt/openclaw/workspace/clash-skill/scripts/clash.sh" start
else
    echo "[$(date)] [BOOT] Error: clash-skill directory not found"
    exit 1
fi
```

---

### Cron 配置

Cron 任务中的路径必须使用绝对路径（或可解析的环境变量），因为 cron 环境没有预先定义的工作目录上下文。

#### 推荐: 使用 $HOME 环境变量

**配置示例**:
```json
{
  "version": 1,
  "jobs": [
    {
      "name": "clash-monitor",
      "schedule": "* * * * *",
      "command": "bash \"$HOME/.openclaw/workspace/clash-skill/scripts/clash-monitor.sh\"",
      "description": "Monitor and restart Clash if not running",
      "enabled": true
    }
  ]
}
```

**重要**:
- `$HOME` 会被 cron 自动展开为用户的 home 目录
- 如果使用自定义路径，将 `$HOME` 替换为实际路径（如 `/home/yourname`）

---

## 🎯 LLM 路径决策指南

LLM 在生成或修改 BOOT.md / Cron 配置时，应遵循以下决策顺序：

### 步骤 1: 检查 clash-skill 相对位置

优先检查是否为 workspace 下的子目录（相对路径可以正常工作）。

```bash
# 假设当前在 workspace 根目录
test -f clash-skill/scripts/clash.sh && echo "RELATIVE_OK"
```

如果判断为相对路径可工作，推荐相对路径。

### 步骤 2: 检查默认安装位置

判断是否满足默认路径 `$HOME/.openclaw/workspace/clash-skill`。

```bash
test -f "$HOME/.openclaw/workspace/clash-skill/scripts/clash.sh" && echo "DEFAULT_OK"
```

如果满足，优先在 BOOT.md 中使用相对路径或在 Cron 中用 `$HOME/.openclaw/workspace`。

### 步骤 3: 使用自动检测脚本

对 BOOT.md，最稳健的做法是内置自动检测（顺序：相对 → 默认用户位置 → 系统位置）。这样可以适应安装变更与重启环境。

### 步骤 4: 针对场景选择绝对或相对

- BOOT.md（在 workspace 下执行）：推荐相对路径；如需要，可同时给出绝对路径作为备选。
- Cron jobs（在最小化环境执行）：必须使用绝对路径或可由 cron 展开的环境变量（优先 `$HOME/.openclaw/workspace`）。

---

## 📝 配置模板

### BOOT.md 完整模板（包含多种方案）

```bash
#!/bin/bash
# OpenClaw Clash 启动脚本

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BOOT] 启动 Clash 代理..."

# 自动检测并启动 Clash
if [ -f "clash-skill/scripts/clash.sh" ]; then
    # 情况 1: 相对路径（clash-skill 在 workspace 根目录）
    bash clash-skill/scripts/clash.sh start
elif [ -f "$HOME/.openclaw/workspace/clash-skill/scripts/clash.sh" ]; then
    # 情况 2: 默认用户位置
    bash "$HOME/.openclaw/workspace/clash-skill/scripts/clash.sh" start
elif [ -f "/opt/openclaw/workspace/clash-skill/scripts/clash.sh" ]; then
    # 情况 3: 系统安装位置
    bash "/opt/openclaw/workspace/clash-skill/scripts/clash.sh" start
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BOOT] 错误: 找不到 clash-skill 目录" >> /tmp/openclaw-boot.log
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BOOT] Clash 启动成功"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BOOT] Clash 启动失败" >> /tmp/openclaw-boot.log
fi
```

### Cron 完整模板

```json
{
  "version": 1,
  "jobs": [
    {
      "name": "clash-monitor",
      "schedule": "* * * * *",
      "command": "bash \"$HOME/.openclaw/workspace/clash-skill/scripts/clash-monitor.sh\"",
      "description": "Monitor and restart Clash if not running",
      "enabled": true
    }
  ]
}
```

---

## ✅ 验证清单

配置完成后，验证以下项目：

**BOOT.md 验证**:
- [ ] BOOT.md 文件存在（通常在 `~/.openclaw/workspace/BOOT.md`）
- [ ] BOOT.md 内容正确（选择合适路径或使用自动检测）
- [ ] boot-md hook 已启用
- [ ] OpenClaw Gateway 重启后 Clash 自动启动

**Cron 验证**:
- [ ] Cron 配置文件存在（`~/.openclaw/cron/jobs.json`）
- [ ] Cron 任务配置正确（绝对路径或 `$HOME` 环境变量）
- [ ] Cron JSON 格式有效（可用 `jq .` 检查）
- [ ] Clash 进程停止后能自动重启

**验证命令**:
```bash
# 检查 BOOT.md
cat ~/.openclaw/workspace/BOOT.md

# 检查 Cron 任务
cat ~/.openclaw/cron/jobs.json

# 验证 Clash 状态
bash ~/.openclaw/workspace/clash-skill/scripts/clash.sh status

# 测试自动启动重启
bash ~/.openclaw/workspace/clash-skill/scripts/clash.sh stop
sleep 65  # 等待 1 分钟以上（依据 Cron 调度）
bash ~/.openclaw/workspace/clash-skill/scripts/clash.sh status
```

---

## 🔧 故障排查

### 问题 1: 路径错误，脚本无法找到

**症状**:
- 启动日志显示 "找不到 clash-skill 目录"
- Cron 执行失败（可在日志中看到）

**解决**:
```bash
# 确认实际路径
find ~ -name "clash-sh" -type d 2>/dev/null

# 更新配置为正确路径
```

### 问题 2: Cron 无法执行

**症状**:
- Clash 停止后未能自动恢复

**解决**:
```bash
# 检查 Cron 配置格式
cat ~/.openclaw/cron/jobs.json | jq .

# 确认路径为绝对路径或包含可解析的环境变量
# 推荐使用 $HOME/.openclaw/workspace/clash-skill/scripts/clash-monitor.sh
```

---

## 📚 相关文档

- **[BOOT.md.example](./BOOT.md.example)** - BOOT.md 配置模板
- **[cron-jobs.json.example](./cron-jobs.json.example)** - Cron 配置详解
- **[SETUP.md](../docs/SETUP.md)** - 完整安装指南
- **[TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md)** - 故障排查指南

---

**最后更新**: 2026-02-27
**文档版本**: 1.0
