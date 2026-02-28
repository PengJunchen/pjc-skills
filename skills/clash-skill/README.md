# Clash Proxy Skill

> 一键安装、管理和监控 Clash 代理的 OpenClaw 技能

---

## ✨ 特性

- ✅ **一键安装** - 自动下载和配置 Clash Meta
- ✅ **订阅链接集成** - 支持通过订阅链接自动导入节点
- ✅ **进程管理** - 便捷的启动/停止/重启/状态查看命令
- ✅ **自动监控** - Cron 定时任务确保服务始终运行
- ✅ **OpenClaw 集成** - Gateway 启动时自动启动代理
- ✅ **代理切换** - 快速切换代理环境变量
- ✅ **节点管理** - REST API 切换和管理节点

---

## 🔧 安装

### 前置要求

- Linux 系统（Ubuntu/Debian/WSL2）
- 可以访问 GitHub 或有代理
- 订阅链接（从代理服务商获取）

### 快速安装

```bash
# 进入技能目录（根据实际情况调整路径）
# 常见 OpenClaw 工作目录：
#   - Linux/WSL2: ~/.openclaw/workspace/clash-skill
#   - 或在当前路径: cd clash-skill
cd ~/.openclaw/workspace/clash-skill

# 运行安装脚本
bash scripts/install.sh <订阅链接>
```

**示例：**
```bash
bash scripts/install.sh https://example.com/sub/your-token
```

详见：[安装指南](docs/SETUP.md)

---

## 🚀 快速开始

### 1. 启动 Clash

```bash
bash scripts/clash.sh start
```

### 2. 启用代理

```bash
source scripts/proxy.sh
```

### 3. 测试连接

```bash
curl -I https://www.google.com
```

---

## 📂 目录结构

```
clash-skill/
├── SKILL.md                      # 技能说明（本文件）
├── README.md                     # 这个文件
├── scripts/                      # 脚本目录
│   ├── install.sh               # 自动安装脚本
│   ├── clash.sh                 # Clash 控制脚本
│   ├── clash-monitor.sh         # 监控脚本
│   └── proxy.sh                 # 代理环境变量脚本
├── docs/                         # 文档目录
│   ├── SETUP.md                 # 详细安装文档
│   ├── USAGE.md                 # 使用指南
│   └── TROUBLESHOOTING.md       # 故障排查
├── config/                       # 配置模板
│   └── config.yaml.example      # 配置文件示例
└── templates/                    # 模板文件
    ├── BOOT.md.example          # OpenClaw 启动钩子模板
    └── cron-jobs.json.example   # Cron 任务配置模板
```

---

## 🛠️ 脚本说明

### install.sh

自动下载并安装 Clash Meta，配置订阅链接。

```bash
bash scripts/install.sh <订阅链接>
```

### clash.sh

管理 Clash 进程（启动/停止/重启/状态）

```bash
bash scripts/clash.sh start    # 启动
bash scripts/clash.sh stop     # 停止
bash scripts/clash.sh restart  # 重启
bash scripts/clash.sh status   # 状态
```

### clash-monitor.sh

监控 Clash 进程，自动重启（用于 Cron）。

```bash
bash scripts/clash-monitor.sh
```

### proxy.sh

快速切换代理环境变量。

```bash
source scripts/proxy.sh         # 启用
source scripts/proxy.sh off     # 禁用
source scripts/proxy.sh status  # 状态
test_proxy()                   # 测试
```

---

## 📊 代理端口

| 类型 | 地址 |
|------|------|
| HTTP | `http://127.0.0.1:7890` |
| SOCKS5 | `socks5://127.0.0.1:7891` |
| API | `http://127.0.0.1:9091` |

---

## 🔌 OpenClaw 集成

### 自动启动（推荐）

将以下内容添加到 OpenClaw 的启动脚本文件中。

**确定 OpenClaw workspace 路径：**

```bash
# 方法 1: 查找 clash-skill 位置
find ~ -name "clash-skill" -type d 2>/dev/null

# 方法 2: 查看配置文件
cat ~/.openclaw/openclaw.json | grep workspace
```

**文件位置分析：**

| 场景 | BOOT.md 位置 | clash-skill 位置 | 推荐方式 |
|------|------------|-----------------|---------|
| 标准安装 | `~/.openclaw/workspace/BOOT.md` | `clash-skill/` 子目录 | 相对路径 |
| 自定义路径 | `/path/to/workspace/BOOT.md` | `clash-skill/` 子目录 | 相对路径 |
| 独立安装 | `~/.openclaw/workspace/BOOT.md` | `/other/path/clash-skill/` | 绝对路径 |

**配置方式1：相对路径（推荐 - clash-skill 在 workspace 根目录）**

文件：`~/.openclaw/workspace/BOOT.md`

```bash
# 启动 Clash（相对路径，从 workspace 根目录执行）
bash clash-skill/scripts/clash.sh start
```

**配置方式2：自动检测路径（最灵活）**

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

详见：[BOOT.md.example](templates/BOOT.md.example)

### Cron 监控（可选）

在 OpenClaw 的 Cron 配置文件中添加定时任务：

- **文件位置**：`~/.openclaw/cron/jobs.json`
- **重要**：Cron 任务必须使用绝对路径（或可解析的环境变量）

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

**注意：** 将 `$HOME` 替换为你的实际 home 目录（如 `/home/yourname`）。

详见：[cron-jobs.json.example](templates/cron-jobs.json.example)

---

## 🌍 节点切换

### 查看节点列表

```bash
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.all'
```

### 切换到指定节点

```bash
curl -X PUT "http://127.0.0.1:9091/proxies/GLOBAL" \
  -H "Content-Type: application/json" \
  -d '{"name":"美国 A01 Youtube无广告 联通高带宽优化"}'
```

---

## 📚 文档

- **[SKILL.md](SKILL.md)** - 技能完整说明
- **[安装指南](docs/SETUP.md)** - 详细安装步骤
- **[使用指南](docs/USAGE.md)** - 日常使用技巧
- **[故障排查](docs/TROUBLESHOOTING.md)** - 常见问题解决

---

## ✅ 验证清单

安装完成后，运行以下命令验证：

- [ ] `clash -v` - 查看版本
- [ ] `bash scripts/clash.sh status` - 查看运行状态
- [ ] `source scripts/proxy.sh` - 启用代理
- [ ] `curl -I https://www.google.com` - 测试 Google
- [ ] `curl -I https://www.youtube.com` - 测试 YouTube

---

## 🔒 安全建议

1. **妥善保管订阅链接** - 订阅链接包含账户信息
2. **监控流量使用** - 避免超出套餐限制
3. **使用 HTTPS** - 访问网站时优先使用 HTTPS
4. **定期更新** - 订阅链接可能有有效期

---

## 🔗 相关资源

- **Clash Meta Wiki**: https://wiki.metacubex.one/
- **Mihomo GitHub**: https://github.com/MetaCubeX/mihomo
- **配置生成器**: https://api.dler.io/

---

## ⚠️ 注意事项

1. **端口占用**: 确保 7890, 7891, 9091 端口未被占用
2. **权限要求**: 需要有 `~/bin` 和 `~/.config/clash` 的写入权限
3. **网络要求**: 首次安装需要访问 GitHub 下载二进制
4. **订阅有效期**: 订阅链接可能过期，需要定期更新

---

## 📝 故障排查

### Clash 无法启动？

1. 检查配置文件：`ls ~/.config/clash/config.yaml`
2. 检查端口占用：`lsof -i:7890`
3. 查看日志：`tail -f /tmp/clash.log`

详见：[故障排查](docs/TROUBLESHOOTING.md)

### 代理无法访问网站？

1. 检查 Clash 状态：`bash scripts/clash.sh status`
2. 检查代理环境变量：`source scripts/proxy.sh status`
3. 切换节点：查看 [使用指南](docs/USAGE.md)

---

## 🆘 获取帮助

如果遇到问题：

1. 查看日志文件：
   - `/tmp/clash.log` - Clash 运行日志
   - `/tmp/clash-monitor.log` - 监控日志

2. 阅读故障排查文档：[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

3. 参考官方文档：
   - [Clash Meta Wiki](https://wiki.metacubex.one/)
   - [Mihomo GitHub Issues](https://github.com/MetaCubeX/mihomo/issues)

---

## 📅 版本信息

- **Clash Meta 版本**: v1.18.10 (Mihomo)
- **技能版本**: 1.0
- **创建日期**: 2026-02-27
- **测试环境**: Debian 12 on WSL2

---

## 📜 许可

本技能基于 MIT 许可证发布。

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**Created by**: OpenClaw Assistant
**Last updated**: 2026-02-27
