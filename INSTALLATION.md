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

2026-02-28 06:18 UTC（初始）
2026-02-28 08:30 UTC（更新 - 添加经验教训）

## 更新记录

- ✅ 创建了 `install-to-openclaw.sh` 脚本
- ✅ 将 clash-skill 正式安装到 `/app/skills/`
- ✅ 清理 workspace 目录，移除重复项目
- ✅ 创建安装文档
- ✅ 添加自动启动工具和 Hook
- ✅ 更新 clash-skill 完整文档

---

## 💡 重要经验教训

### 1. 路径配置的重要性

**问题**: OpenClaw Hook 中的路径可能因为环境不同而失败

**教训**:
- 在 WSL2 和 Docker 容器环境中，`~/.openclaw/workspace/` 可能不是实际路径
- 使用相对路径或多路径检测策略更可靠
- 不要硬编码绝对路径

**在 install-to-openclaw.sh 中的改进**:
- 脚本使用 `$(dirname "$BASH_SOURCE")")` 动态获取脚本位置
- 这种方法在任何环境中都能正确工作

### 2. 进程检测的陷阱

**问题**: 使用 `pgrep -f clash` 进行模糊匹配导致误报

**教训**:
- `pgrep -f` 会匹配命令行，导致匹配自身
- 应该使用 `pgrep -x` 进行精确匹配
- 验证 PID 文件中的进程是否存在
- 使用 `stdio: "pipe"` 防止命令输出干扰检测

详见: [`clash-skill/CLASH_AUTO_STARTUP_COMPLETE.md`](skills/clash-skill/CLASH_AUTO_STARTUP_COMPLETE.md)

### 3. OpenClaw Hook 的局限性

**发现**:
- `gateway:startup` hook 在某些情况下可能不会触发
- 原因可能是：
  1. Hook 加载顺序问题
  2. 事件触发时机不匹配
  3. OpenClaw 版本差异
  4. 容器/WSL2 环境特殊性

**解决方案**:
- **推荐**: 使用 BOOT.md（boot-md hook）- 已验证可行
- **高级选项**: Gateway Hook - 可以获取详细日志，但不保证触发
- **最后保障**: Cron @reboot - 系统级，最可靠

### 4. 多层次启动策略

**最佳实践**:

| 层次 | 方法 | 作用 | 紧急程度 |
|------|------|------|---------|
| 第1层 | BOOT.md | 主要启动方案（简单、可靠） | 🔴 必须 |
| 第2层 | Gateway Hook | 高级控制、详细日志（可选） | 🟡 推荐高级用户 |
| 第3层 | Cron @reboot | 备用方案、系统级 | 🟢 推荐WSL2/容器 |

**不要只依赖单一方法！**

### 5. 工具可观测性

**新增工具的重要性**:

1. **check-status.sh** - 状态检查工具
   - 一键检查所有相关状态
   - 快速定位问题

2. **详细的日志系统**:
   - `/tmp/clash-startup.log` - Hook 主日志
   - `/tmp/clash-startup-debug.log` - 详细调试日志
   - `/tmp/boot.log` - BOOT.md 日志
   - `/tmp/clash-cron.log` - Cron 日志

3. **诊断流程**:
   每次遇到问题时，先运行 `check-status.sh`，根据输出决定下一步

---

## 📦 完整的技能目录结构

安装到 `/app/skills/clash-skill/` 后的目录结构：

```
/app/skills/clash-skill/
├── SKILL.md                          # 技能说明文档（已更新）
├── CLASH_AUTO_STARTUP_COMPLETE.md    # 完整的自动启动解决方案（新增）
├── scripts/                          # 脚本目录
│   ├── install.sh                   # 安装脚本
│   ├── clash.sh                     # Clash 控制
│   ├── clash-monitor.sh             # 监控脚本
│   ├── clash-cron-startup.sh        # Cron 启动（新增）
│   └── proxy.sh                     # 代理环境变量
├── tools/                            # 工具目录（新增）
│   └── check-status.sh              # 状态检查工具（新增）
├── hooks/                            # OpenClaw Hooks（新增）
│   └── clash-startup/               # Gateway Startup Hook（新增）
│       ├── HOOK.md                  # Hook 元数据
│       ├── handler.js               # Hook 处理器（推荐）
│       └── handler.ts               # TypeScript 版本
├── docs/                             # 文档目录
│   ├── SETUP.md                     # 安装文档
│   ├── USAGE.md                     # 使用指南
│   └── TROUBLESHOOTING.md           # 故障排查
└── templates/                        # 模板文件
    ├── BOOT.md                      # BOOT.md 模板（更新）
    └── cron-jobs.json.example       # Cron 配置示例
```

---

## 🔄 推荐的安装和配置流程

### 首次安装

```bash
# 1. 安装技能
cd ~/.openclaw/workspace/pjc-skills
bash install-to-openclaw.sh

# 2. 将 clash-skill 部署到 workspace
mkdir -p ~/.openclaw/workspace
cp -r ~/.openclaw/workspace/pjc-skills/skills/clash-skill \
      ~/.openclaw/workspace/clash-skill

# 3. 配置 BOOT.md（推荐）
cp ~/.openclaw/workspace/clash-skill/templates/BOOT.md \
   ~/.openclaw/workspace/BOOT.md
# 根据需要编辑路径

# 4. 配置 OpenClaw
cat ~/.openclaw/openclaw.json | grep -E "boot-md|hooks"
# 确认 boot-md.enabled = true

# 5. 测试
openclaw gateway restart
sleep 5
bash ~/.openclaw/workspace/clash-skill/scripts/clash.sh status
```

### 已有技能用户（更新）

```bash
# 1. 更新技能文件
cd ~/.openclaw/workspace/pjc-skills
git pull  # 或重新下载

# 2. 重新安装
bash install-to-openclaw.sh

# 3. 检查新增工具
ls -la ~/.openclaw/workspace/clash-skill/tools/
ls -la ~/.openclaw/workspace/clash-skill/hooks/

# 4. 运行状态检查
bash ~/.openclaw/workspace/clash-skill/tools/check-status.sh
```

### 高级用户（完整功能）

```bash
# 额外配置选项

# 选项 1: 部署 Gateway Hook
cp -r ~/.openclaw/workspace/clash-skill/hooks/clash-startup \
      ~/.openclaw/workspace/hooks/

# 编辑 ~/.openclaw/openclaw.json 添加 hook 配置

# 选项 2: 配置 Cron 备用方案
cp ~/.openclaw/workspace/clash-skill/scripts/clash-cron-startup.sh \
   ~/clash-cron-startup.sh
chmod +x ~/clash-cron-startup.sh

(crontab -l 2>/dev/null; \
  echo "@reboot sleep 60 && /home/node/clash-cron-startup.sh >> /tmp/clash-cron.log 2>&1") | crontab -

# 验证所有配置
bash ~/.openclaw/workspace/clash-skill/tools/check-status.sh
```

---

## 📚 重要文档

安装完成后，请务必阅读：

1. **[`SKILL.md`](skills/clash-skill/SKILL.md)** - 完整技能说明（已更新）
2. **[`CLASH_AUTO_STARTUP_COMPLETE.md`](skills/clash-skill/CLASH_AUTO_STARTUP_COMPLETE.md)** - 自动启动完整解决方案（必读）
3. **[`docs/SETUP.md`](skills/clash-skill/docs/SETUP.md)** - 详细安装文档
4. **[`docs/TROUBLESHOOTING.md`](skills/clash-skill/docs/TROUBLESHOOTING.md)** - 故障排查指南

---

## ✅ 安装验证清单

完成安装后，验证以下项目：

### 基础验证
- [ ] `/app/skills/clash-skill/SKILL.md` 存在
- [ ] `clash -v` 能显示版本
- [ ] `bash scripts/clash.sh status` 可以运行

### 自动启动验证
- [ ] `~/.openclaw/workspace/BOOT.md` 存在
- [ ] `~/.openclaw/openclaw.json` 中 `boot-md.enabled = true`
- [ ] 重启 Gateway 后 Clash 自动启动

### 工具验证
- [ ] `tools/check-status.sh` 可以运行
- [ ] `/tmp/boot.log` 在重启后有内容（如果使用 BOOT.md）
- [ ] `/tmp/clash-startup-debug.log` 存在（如果使用 Gateway Hook）

### 功能验证
- [ ] `curl -I https://www.google.com` 成功（直连）
- [ ] `source scripts/proxy.sh && curl -I https://www.google.com` 成功（代理）
- [ ] Clash 控制面板可以访问：http://127.0.0.1:9091

---

## 🆘 常见安装问题

### 问题：Skills 未被识别

**原因**: `/app/skills/clash-skill/SKILL.md` 不存在或格式错误

**解决**:
```bash
# 重新运行安装脚本
cd ~/.openclaw/workspace/pjc-skills
bash install-to-openclaw.sh

# 验证
ls -la /app/skills/clash-skill/SKILL.md
cat /app/skills/clash-skill/SKILL.md | head -20
```

### 问题：Clash 启动失败

**原因**: 端口冲突、配置错误、权限问题

**解决**:
```bash
# 运行状态检查
bash ~/.openclaw/workspace/clash-skill/tools/check-status.sh

# 查看详细日志
tail -50 /tmp/clash.log

# 尝试手动启动
bash scripts/clash.sh start
```

详见: [`docs/TROUBLESHOOTING.md`](skills/clash-skill/docs/TROUBLESHOOTING.md)

---

**文档最后更新**: 2026-02-28 08:30 UTC
