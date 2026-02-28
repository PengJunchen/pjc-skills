# Clash Proxy Skill

**Clash 自动化安装、配置和管理技能**

---

## 📖 技能说明

**支持平台**：仅支持 Linux 系统（包括 Ubuntu/Debian 和 WSL2）

这是一个完整的 Clash 代理管理技能，可以帮助用户：

1. ✅ **自动安装 Clash Meta (Mihomo)**
2. ✅ 配置和管理代理节点（订阅链接模式）
3. ✅ 提供便捷的控制和监控脚本
4. ✅ 代理环境变量快速切换
5. ✅ 集成到 OpenClaw 实现自动启动

**使用前提**：用户需要提供有效的 Clash 订阅链接（从代理服务商获取）

---

## 🎯 何时使用

当你需要：

- 搭建或配置代理服务器以访问受限服务
- 管理多个代理节点和切换节点
- 在命令行工具中快速启用/禁用代理
- 确保 OpenClaw 启动时代理服务自动运行
- 监控代理服务状态并自动重启

---

## ⚡ 快速开始

### 1. 安装 Clash

```bash
# 进入技能目录（根据实际情况调整路径）
# 常见 OpenClaw 工作目录：
#   - Linux/WSL2: ~/.openclaw/workspace/clash-skill
#   - 或在当前路径: cd clasheskill
cd ~/.openclaw/workspace/clash-skill

# 运行安装脚本
bash scripts/install.sh <订阅链接>
```

### 2. 启动代理

```bash
# 启动 Clash
bash scripts/clash.sh start

# 启用代理环境变量
source scripts/proxy.sh
```

### 3. 测试连接

```bash
# 测试 Google 访问
curl -I https://www.google.com

# 测试 YouTube
curl -I https://www.youtube.com
```

---

## 📂 目录结构

```
clash-skill/
├── SKILL.md                          # 本文件
├── CLASH_AUTO_STARTUP_COMPLETE.md    # 完整的自动启动解决方案文档
├── scripts/                          # 脚本目录
│   ├── install.sh                   # 自动安装脚本
│   ├── clash.sh                     # Clash 控制脚本
│   ├── clash-monitor.sh             # 监控脚本
│   ├── clash-cron-startup.sh        # Cron 启动脚本
│   └── proxy.sh                     # 代理环境变量脚本
├── tools/                            # 工具目录
│   └── check-status.sh              # 状态检查工具
├── hooks/                            # OpenClaw Hook 目录
│   └── clash-startup/               # Gateway Startup Hook
│       ├── HOOK.md                  # Hook 元数据
│       ├── handler.js               # Hook 处理器（推荐）
│       └── handler.ts               # TypeScript 版本（可选）
├── docs/                             # 文档目录
│   ├── SETUP.md                     # 详细安装文档
│   ├── USAGE.md                     # 使用指南
│   └── TROUBLESHOOTING.md           # 故障排查
└── templates/                        # 模板文件
    ├── BOOT.md                      # BOOT.md 模板
    └── cron-jobs.json.example       # Cron 任务配置模板
```

---

## 🛠️ 脚本说明

### scripts/install.sh
**功能**: 自动下载并安装 Clash Meta，配置订阅链接

```bash
# 使用方法
bash scripts/install.sh <订阅链接>

# 示例
bash scripts/install.sh https://example.com/sub/your-token
```

### scripts/clash.sh
**功能**: 管理 Clash 进程（启动/停止/重启/状态）

```bash
bash scripts/clash.sh start    # 启动 Clash
bash scripts/clash.sh stop     # 停止 Clash
bash scripts/clash.sh restart  # 重启 Clash
bash scripts/clash.sh status   # 查看状态
```

### scripts/clash-monitor.sh
**功能**: 监控 Clash 进程，自动重启（用于 Cron）

```bash
# 配置到 cron 每分钟执行
* * * * * bash /home/node/.openclaw/workspace/clash-skill/scripts/clash-monitor.sh
```

### scripts/proxy.sh
**功能**: 快速切换代理环境变量

```bash
source scripts/proxy.sh         # 启用代理
source scripts/proxy.sh off     # 禁用代理
source scripts/proxy.sh status  # 查看状态
test_proxy()                   # 测试代理连接
```

### scripts/clash-cron-startup.sh
**功能**: 用于 Cron @reboot 任务的启动脚本

```bash
# 添加到 crontab
(crontab -l 2>/dev/null; echo "@reboot sleep 60 && /path/to/clash-cron-startup.sh >> /tmp/clash-cron.log 2>&1") | crontab -
```

特点：
- 等待系统启动（默认60秒）
- 检查是否已在运行
- 验证启动结果
- 完整的日志记录（/tmp/clash-cron.log）

### tools/check-status.sh
**功能**: 综合状态检查工具

```bash
bash tools/check-status.sh
```

输出内容：
- Gateway 进程状态
- Clash 进程状态
- Hook 日志状态（clash-startup-debug.log）
- Clash 状态检查
- Hook 配置验证

这个脚本是排查自动启动问题的第一个工具。

### hooks/clash-startup/
**功能**: OpenClaw Gateway Hook - 高级自动启动方案

**文件结构**:
```
hooks/clash-startup/
├── HOOK.md       # Hook 元数据描述
├── handler.js    # Hook 处理器（JavaScript，推荐）
└── handler.ts    # TypeScript 版本（可选）
```

**安装步骤**:

1. **复制 hook 到 workspace**:
```bash
cp -r hooks/clash-startup ~/.openclaw/workspace/hooks/
```

2. **配置 OpenClaw**:
在 `~/.openclaw/openclaw.json` 中添加：

```json
{
  "hooks": {
    "internal": {
      "enabled": true,
      "entries": {
        "clash-startup": {
          "enabled": true
        }
      }
    }
  }
}
```

3. **重启 Gateway**:
```bash
openclaw gateway restart
```

**Hook 日志**:
- 主日志: `/tmp/clash-startup.log`
- 调试日志: `/tmp/clash-startup-debug.log`

---

## 🔧 配置说明

### 代理端口

| 类型 | 地址 | 说明 |
|------|------|------|
| HTTP | `http://127.0.0.1:7890` | HTTP 代理 |
| SOCKS5 | `socks5://127.0.0.1:7891` | SOCKS5 代理 |
| API | `http://127.0.0.1:9091` | 控制面板 API |

### 配置文件

- **主配置**: `~/.config/clash/config.yaml`
- **PID 文件**: `~/.config/clash/clash.pid`
- **日志文件**: `/tmp/clash.log`
- **监控日志**: `/tmp/clash-monitor.log`

---

## 🚀 OpenClaw 集成

### 自动启动方案总览

本 skill 提供三种自动启动方案，按可靠性排序：

| 方案 | 复杂度 | 可靠性 | 推荐度 | 适用场景 |
|------|--------|--------|--------|----------|
| BOOT.md | 简单 | 高 | ⭐⭐⭐⭐⭐ | 日常使用（推荐） |
| Gateway Hook | 复杂 | 中 | ⭐⭐⭐⭐ | 高级用户，需要详细日志 |
| Cron | 中 | 最高 | ⭐⭐⭐ | 备用方案，WSL2/容器环境 |

详见：[`CLASH_AUTO_STARTUP_COMPLETE.md`](./CLASH_AUTO_STARTUP_COMPLETE.md)

---

### 方案 A：BOOT.md（推荐 - 首选）

**优点**:
- ✅ 最简单的实现
- ✅ OpenClaw 内置功能
- ✅ 已验证可行

**配置步骤**:

1. **确定 workspace 路径**:

```bash
# 方法 1: 查找 clash-skill 位置
find ~ -name "clash-skill" -type d 2>/dev/null

# 方法 2: 查看配置文件
cat ~/.openclaw/openclaw.json | grep workspace
```

2. **确保 clash-skill 在 workspace 目录**:

```bash
# 检查当前结构
ls ~/.openclaw/workspace/clash-skill/scripts/clash.sh

# 如果不存在，复制
cp -r ~/.openclaw/workspace/pjc-skills/skills/clash-skill ~/.openclaw/workspace/clash-skill
```

3. **创建 BOOT.md**:

文件：`~/.openclaw/workspace/BOOT.md`

```bash
# OpenClaw Boot Hook - Clash 自动启动
# 在 Gateway 启动时启动 Clash

bash clash-skill/scripts/clash.sh start
bash clash-skill/scripts/clash.sh status
```

或者使用模板：
```bash
cp templates/BOOT.md ~/.openclaw/workspace/BOOT.md
# 根据实际情况编辑路径
```

4. **启用 boot-md**:

在 `~/.openclaw/openclaw.json` 中确认：

```json
{
  "boot-md": {
    "enabled": true
  }
}
```

5. **测试**:

```bash
# 重启 Gateway
openclaw gateway restart

# 检查日志
cat /tmp/boot.log

# 检查 Clash 状态
bash ~/.openclaw/workspace/clash-skill/scripts/clash.sh status
```

---

### 方案 B：OpenClaw Gateway Hook（高级用户）

**优点**:
- ✅ 精确控制启动时机
- ✅ 详细的调试日志
- ✅ 支持复杂逻辑

**详见**: [`hooks/clash-startup/`](./hooks/clash-startup/) 和完整文档

**简要配置**:

```bash
# 1. 复制 hook
cp -r hooks/clash-startup ~/.openclaw/workspace/hooks/

# 2. 配置 openclaw.json
# 手动编辑或使用 agent 修改配置

# 3. 重启 Gateway
openclaw gateway restart

# 4. 查看日志
cat /tmp/clash-startup.log
cat /tmp/clash-startup-debug.log
```

---

### 方案 C：Cron（备用方案）

**优点**:
- ✅ 系统级，不依赖 OpenClaw
- ✅ 最可靠
- ✅ 适用于 WSL2 和容器环境

**配置步骤**:

**方法 1：使用提供的脚本**:

```bash
# 复制脚本
cp scripts/clash-cron-startup.sh ~/clash-cron-startup.sh

# 编辑路径（如果需要）
vi ~/clash-cron-startup.sh

# 添加到 crontab
(crontab -l 2>/dev/null; echo "@reboot sleep 60 && /home/node/clash-cron-startup.sh >> /tmp/clash-cron.log 2>&1") | crontab -
```

**方法 2：直接使用 clash.sh**:

```bash
# 简化版本
(crontab -l 2>/dev/null; echo "@reboot sleep 60 && bash /home/node/.openclaw/workspace/clash-skill/scripts/clash.sh start >> /tmp/clash-cron.log 2>&1") | crontab -

# 查看配置
crontab -l
```

**WSL2 注意事项**:

在 WSL2 中，可能需要更长的等待时间（90-120秒）以确保网络就绪：

```bash
# WSL2 建议配置
(crontab -l 2>/dev/null; echo "@reboot sleep 90 && bash /path/to/clash.sh start >> /tmp/clash-cron.log 2>&1") | crontab -
```

---

### 自动启动验证

**使用状态检查工具**:

```bash
# 运行综合检查
bash tools/check-status.sh
```

**手动验证步骤**:

```bash
# 1. 停止 Clash
bash scripts/clash.sh stop

# 2. 清除日志（可选）
> /tmp/clash-startup.log
> /tmp/clash-startup-debug.log
> /tmp/boot.log
> /tmp/clash-cron.log

# 3. 重启 Gateway
openclaw gateway restart

# 4. 等待 2-3 分钟

# 5. 检查状态
bash scripts/clash.sh status

# 6. 检查日志
echo "=== BOOT.md log ==="
cat /tmp/boot.log 2>/dev/null || echo "不存在"

echo ""
echo "=== Hook log ==="
cat /tmp/clash-startup.log 2>/dev/null || echo "不存在"

echo ""
echo "=== Debug log ==="
cat /tmp/clash-startup-debug.log 2>/dev/null || echo "不存在"

echo ""
echo "=== Cron log ==="
cat /tmp/clash-cron.log 2>/dev/null || echo "不存在"
```

---

## 📊 节点切换

### 通过 API 切换节点

```bash
# 切换到美国节点
curl -X PUT "http://127.0.0.1:9091/proxies/GLOBAL" \
  -H "Content-Type: application/json" \
  -d '{"name":"美国 A01 Youtube无广告 联通高带宽优化"}'
```

### 获取节点列表

```bash
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.now, .all'
```

---

## 📝 文档索引

- **[完整解决方案文档](CLASH_AUTO_STARTUP_COMPLETE.md)** - 自动启动的完整解决方案与经验总结
- **[详细安装文档](docs/SETUP.md)** - 完整的安装步骤和配置说明
- **[使用指南](docs/USAGE.md)** - 日常使用技巧和高级功能
- **[故障排查](docs/TROUBLESHOOTING.md)** - 常见问题和解决方案

---

## 🔧 故障排查 - 自动启动专用

### 问题：Gateway 重启后 Clash 没有自动启动

**排查步骤**:

1. **运行状态检查工具**:
```bash
bash tools/check-status.sh
```

2. **检查 BOOT.md 是否存在**:
```bash
ls -la ~/.openclaw/workspace/BOOT.md
cat ~/.openclaw/workspace/BOOT.md
```

3. **检查 boot-md 是否启用**:
```bash
grep -A 2 "boot-md" ~/.openclaw/openclaw.json
```

4. **检查日志文件**:
```bash
echo "=== BOOT.md log ==="
cat /tmp/boot.log

echo ""
echo "=== Hook log (如果使用 Gateway Hook) ==="
cat /tmp/clash-startup.log

echo ""
echo "=== Cron log (如果使用 Cron) ==="
cat /tmp/clash-cron.log
```

5. **手动测试启动命令**:
```bash
cd ~/.openclaw/workspace
bash clash-skill/scripts/clash.sh start
bash clash-skill/scripts/clash.sh status
```

### 问题：Hook 触发但 Clash 未启动

**可能原因**:
- 路径配置错误
- 权限问题
- 端口冲突

**解决方案**:

1. **检查路径**:
```bash
# 验证脚本路径
ls -la ~/.openclaw/workspace/clash-skill/scripts/clash.sh
ls -la /home/node/.openclaw/workspace/clash-skill/scripts/clash.sh
ls -la /path/you/configured/scripts/clash.sh
```

2. **检查端口占用**:
```bash
# 检查 7890, 7891, 9091 端口
netstat -tlnp | grep -E '7890|7891|9091'
lsof -i :7890 2>/dev/null
```

3. **查看 Clash 详细日志**:
```bash
tail -50 /tmp/clash.log
```

### 问题：僵尸进程（PID 文件存在但进程不存在）

**症状**:
```bash
$ bash clash.sh status
📊 Clash 状态: 僵尸进程 (PID文件存在但进程不存在)
```

**解决方案**:
```bash
# 清除 PID 文件并重启
rm ~/.config/clash/clash.pid
bash scripts/clash.sh start
```

**预防措施**:
- 使用 BOOT.md（会在启动时自动检测）
- 配置 cron 监控脚本
- 使用 Gateway Hook 的自动恢复功能

### 问题：在 WSL2 中网络代理不可用

**可能原因**:
- 网络未就绪
- 防火墙或安全软件阻止
- DNS 解析问题

**解决方案**:

1. **增加启动等待时间**（Cron 方案）:
```bash
# 将等待时间从 60 秒增加到 90-120 秒
sed -i 's/sleep 60/sleep 90/' ~/clash-cron-startup.sh
```

2. **测试网络连接**:
```bash
# 测试直连
curl -I https://www.google.com

# 测试代理
curl -x http://127.0.0.1:7890 -I https://www.google.com
```

3. **检查 Clash 订阅**:
```bash
# 更新订阅
bash scripts/clash.sh stop
# 删除旧配置
rm ~/.config/clash/config.yaml
# 重新安装或更新订阅
# ...
bash scripts/clash.sh start
```

### 问题：Hook 日志显示 "Event type mismatch"

**原因**: HOOK.md 中配置的事件类型与实际触发的事件不匹配。

**检查**:
```bash
# 查看 HOOK.md
cat ~/.openclaw/workspace/hooks/clash-startup/HOOK.md

# 正确配置应该是：
# openclaw:
#   events: ["gateway:startup"]
```

**修复**:
编辑 HOOK.md 确保使用正确的事件类型：`gateway:startup`

### 问题：找不到 clash-skill 目录

**错误信息**:
```
Error: clash-skill directory not found
```

**解决方案**:

1. **查找位置**:
```bash
find ~ -name "clash-skill" -type d 2>/dev/null
```

2. **更新脚本中的路径**:
根据找到的路径，更新：
- BOOT.md
- handler.js (如果使用 Gateway Hook)
- crontab (如果使用 Cron)

3. **创建符号链接**（可选）:
```bash
# 如果 clash-skill 在 pjc-skills 下
ln -s ~/.openclaw/workspace/pjc-skills/skills/clash-skill \
      ~/.openclaw/workspace/clash-skill
```

---

## ⚠️ 注意事项

1. **订阅链接安全**: 订阅链接包含敏感信息，请妥善保管
2. **端口冲突**: 确保 7890, 7891, 9091 端口未被占用
3. **权限要求**: 需要有 `~/bin` 和 `~/.config/clash` 的写入权限
4. **路径配置**: 确保脚本中的路径与实际安装位置一致
5. **WSL2 用户**: 建议使用 Cron 方案，并增加等待时间（90-120秒）
6. **容器环境**: 某些容器可能需要特殊处理（如修改 WORKDIR）

---

## 🔗 相关资源

- **Clash Meta 官方文档**: https://wiki.metacubex.one/
- **Mihomo GitHub**: https://github.com/MetaCubeX/mihomo
- **配置生成器**: https://api.dler.io/

---

## 📅 版本信息

- **Clash Meta 版本**: v1.18.10 (Mihomo)
- **技能创建日期**: 2026-02-27
- **测试环境**: Debian 12 on WSL2
- **自动启动方案更新**: 2026-02-28
- **经验总结**: [`CLASH_AUTO_STARTUP_COMPLETE.md`](./CLASH_AUTO_STARTUP_COMPLETE.md)

## 🔧 新增工具（2026-02-28）

为解决自动启动问题，新增以下工具和文档：

| 工具/文档 | 位置 | 说明 |
|----------|------|------|
| `check-status.sh` | `tools/` | 综合状态检查工具 |
| `clash-cron-startup.sh` | `scripts/` | Cron 启动脚本 |
| `clash-startup/` | `hooks/` | Gateway Hook 实现 |
| `BOOT.md` | `templates/` | BOOT.md 模板 |
| `CLASH_AUTO_STARTUP_COMPLETE.md` | 根目录 | 完整解决方案文档 |

---

## ✅ 验证清单

安装完成后，运行以下命令验证：

- [ ] `clash -v` 查看版本
- [ ] `bash scripts/clash.sh status` 查看运行状态
- [ ] `curl -I https://www.google.com` 测试 Google 访问
- [ ] `curl -I https://www.youtube.com` 测试 YouTube 访问
- [ ] `curl -I https://github.com` 测试 GitHub 访问

---

**Created by**: OpenClaw Assistant
**Last updated**: 2026-02-27 03:27 UTC
