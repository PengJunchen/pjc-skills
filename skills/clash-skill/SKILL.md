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
├── SKILL.md                # 本文件
├── scripts/                # 脚本目录
│   ├── install.sh         # 自动安装脚本
│   ├── clash.sh           # Clash 控制脚本
│   ├── clash-monitor.sh   # 监控脚本
│   └── proxy.sh           # 代理环境变量脚本
├── docs/                   # 文档目录
│   ├── SETUP.md           # 详细安装文档
│   ├── USAGE.md           # 使用指南
│   └── TROUBLESHOOTING.md # 故障排查
├── config/                 # 配置模板
│   └── config.yaml.example # 配置示例
└── templates/              # 模板文件
    ├── BOOT.md.example           # OpenClaw 启动钩子模板
    └── cron-jobs.json.example   # Cron 任务配置模板
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

### 自动启动（推荐）

将以下内容添加到 OpenClaw 的启动脚本文件中：

**确定 OpenClaw workspace 路径：**

```bash
# 方法 1: 查找 clash-skill 位置
find ~ -name "clash-skill" -type d 2>/dev/null

# 方法 2: 查看配置文件
cat ~/.openclaw/openclaw.json | grep workspace
```

**文件位置分析：**

| 场景 | BOOT.md 位置 | clash-skill 相对位置 | 推荐命令 |
|------|------------|-------------------|---------|
| 标准用户安装 | `~/.openclaw/workspace/BOOT.md` | `clash-skill/` 子目录 | `bash clash-skill/scripts/clash.sh start` |
| 自定义安装 | `/path/to/workspace/BOOT.md` | `clash-skill/` 子目录 | `bash clash-skill/scripts/clash.sh start` |
| 分离安装 | `~/.openclaw/workspace/BOOT.md` | `/other/path/clash-skill/` | 使用绝对路径 |

**推荐配置方式1：相对路径（当 clash-skill 在 workspace 根目录下时）**

文件：`~/.openclaw/workspace/BOOT.md`

```bash
# 启动 Clash（相对路径，从 workspace 根目录执行）
bash clash-skill/scripts/clash.sh start
```

**推荐配置方式2：自动检测路径（最灵活）**

文件：`~/.openclaw/workspace/BOOT.md`

```bash
# 自动检测 clash-skill 目录并启动
if [ -f "clash-skill/scripts/clash.sh" ]; then
    bash clash-skill/scripts/clash.sh start
elif [ -f "$HOME/.openclaw/workspace/clash-skill/scripts/clash.sh" ]; then
    bash "$HOME/.openclaw/workspace/clash-skill/scripts/clash.sh" start
elif [ -f "/opt/openclaw/workspace/clash-skill/scripts/clash.sh" ]; then
    bash "/opt/openclaw/workspace/clash-skill/scripts/clash.sh" start
else
    echo "[$(date)] [BOOT] Error: clash-skill directory not found"
fi
```

### Cron 监控（可选）

在 OpenClaw 的 Cron 配置文件中添加定时任务。

**文件位置：** `~/.openclaw/cron/jobs.json`

**重要：** cron 任务必须使用绝对路径（或可解析的环境变量）。

```json
{
  "version": 1,
  "jobs": [
    {
      "name": "clash-monitor",
      "schedule": "* * * * *",
      "command": "bash \"$HOME/.openclaw/workspace/clash-skill/scripts/clash-monitor.sh\"",
      "description": "Monitor and restart Clash if needed"
    }
  ]
}
```

**注意：** 将 `$HOME` 替换为你的实际 home 目录（如 `/home/yourname`），或使用 `$(echo ~)` 获取。

详见配置模板文件：
- [BOOT.md.example](templates/BOOT.md.example) - 包含多种路径配置方案
- [cron-jobs.json.example](templates/cron-jobs.json.example) - Cron 路径配置详解

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

- **[详细安装文档](docs/SETUP.md)** - 完整的安装步骤和配置说明
- **[使用指南](docs/USAGE.md)** - 日常使用技巧和高级功能
- **[故障排查](docs/TROUBLESHOOTING.md)** - 常见问题和解决方案

---

## ⚠️ 注意事项

1. **订阅链接安全**: 订阅链接包含敏感信息，请妥善保管
2. **端口冲突**: 确保 7890, 7891, 9091 端口未被占用
3. **权限要求**: 需要有 `~/bin` 和 `~/.config/clash` 的写入权限
4. **定时任务**: Cron 监控是可选的，OpenClaw 启动钩子已足够

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
