# Clash 代理安装完整指南

---

## 📋 系统要求

- **操作系统**: Linux (推荐 Debian/Ubuntu, WSL2 也支持)
- **架构**: x86_64 或 ARM64
- **网络**: 需要可以访问 GitHub 或有代理
- **权限**: 需要有 `~/bin` 和 `~/.config` 的写入权限

---

## 📦 安装步骤

### 步骤 1: 获取订阅链接

你需要一个 Clash 代理服务的订阅链接。通常格式为：
```
https://example.com/sub/your-token
```

**注意**: 订阅链接包含敏感信息，请妥善保管。

---

### 步骤 2: 运行安装脚本

```bash
# 进入技能目录（根据实际情况调整路径）
# 常见 OpenClaw 工作目录：
#   - Linux/WSL2: ~/.openclaw/workspace/clash-skill
#   - 或在当前路径: cd clash-skill
cd ~/.openclaw/workspace/clash-skill

# 或使用 find 查找 clash-skill 位置
cd $(find ~ -name "clash-skill" -type d 2>/dev/null | head -1)

# 运行安装脚本
bash scripts/install.sh <订阅链接>
```

如果网络无法直接访问 GitHub，可以设置代理：

```bash
# 设置代理
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# 然后重新安装
bash scripts/install.sh <订阅链接>
```

---

### 步骤 3: 更新 PATH

如果 `.bashrc` 中还没有 `~/bin`，安装脚本会自动添加。重新加载配置：

```bash
source ~/.bashrc
```

---

### 步骤 4: 验证安装

```bash
# 检查 Clash 版本
clash -v

# 应该输出类似:
# Mihomo v1.18.10 (a45f642)
```

---

## 🚀 启动 Clash

### 使用控制脚本启动

```bash
bash scripts/clash.sh start
```

输出示例：
```
🚀 启动 Clash Meta...
✓ Clash 启动成功 (PID: 12345)
  HTTP 代理: http://127.0.0.1:7890
  SOCKS 代理: socks5://127.0.0.1:7891
  控制面板: http://127.0.0.1:9091

📶 启用代理: source scripts/proxy.sh
```

---

## 📊 验证代理工作

### 启用代理环境变量

```bash
source scripts/proxy.sh
```

### 测试连接

```bash
# 测试 Google
curl -I https://www.google.com

# 测试 YouTube
curl -I https://www.youtube.com

# 测试 GitHub
curl -I https://github.com
```

如果所有测试都成功（返回 HTTP 200），说明代理配置成功！

---

## 🔧 常用命令

### Clash 控制

```bash
# 启动
bash scripts/clash.sh start

# 停止
bash scripts/clash.sh stop

# 重启
bash scripts/clash.sh restart

# 状态
bash scripts/clash.sh status
```

### 代理控制

```bash
# 启用代理
source scripts/proxy.sh

# 禁用代理
source scripts/proxy.sh off

# 查看状态
source scripts/proxy.sh status

# 测试代理
test_proxy
```

---

## 🌐 OpenClaw 集成

### 方法 1: 启动钩子（推荐）

**第一步：确定 OpenClaw workspace 路径**

```bash
# 方法 1: 查找 clash-skill 位置
find ~ -name "clash-skill" -type d 2>/dev/null

# 方法 2: 查看配置文件
cat ~/.openclaw/openclaw.json | grep workspace
```

**第二步：分析文件位置关系**

| 场景 | BOOT.md 位置 | clash-skill 位置 | 推荐方式 |
|------|------------|-----------------|---------|
| 标准安装 | `~/.openclaw/workspace/BOOT.md` | `clash-skill/` 子目录 | 相对路径 |
| 自定义路径 | `/path/to/workspace/BOOT.md` | `clash-skill/` 子目录 | 相对路径 |
| 独立安装 | `~/.openclaw/workspace/BOOT.md` | `/other/path/clash-skill/` | 绝对路径 |

**第三步：选择配置方式**

**配置方式1：相对路径（最简单）**

适合：clash-skill 作为 workspace 根目录下的子目录

文件：`~/.openclaw/workspace/BOOT.md`

```bash
# 启动 Clash（相对路径，从 workspace 根目录执行）
bash clash-skill/scripts/clash.sh start
```

**配置方式2：绝对路径（明确指定）**

适合：需要明确指定完整路径

文件：`~/.openclaw/workspace/BOOT.md`

```bash
# 使用环境变量或明确路径
CLASH_SKILL_DIR="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}/clash-skill"
bash "$CLASH_SKILL_DIR/scripts/clash.sh" start
```

**配置方式3：自动检测路径（最灵活）**

适合：不确定具体安装位置，需要自动检测

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
    exit 1
fi
```

这样每次 OpenClaw Gateway 启动时，Clash 会自动启动。

详见：[BOOT.md.example](../templates/BOOT.md.example)

### 方法 2: Cron 监控（可选）

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

**注意**：将 `$HOME` 替换为你的实际 home 目录（如 `/home/yourname`）。

这会每分钟检查一次 Clash 状态，如果进程不存在会自动启动。

详见：[cron-jobs.json.example](../templates/cron-jobs.json.example)

---

## 📂 文件位置

| 文件 | 位置 |
|------|------|
| Clash 二进制 | `~/bin/clash` |
| 配置文件 | `~/.config/clash/config.yaml` |
| PID 文件 | `~/.config/clash/clash.pid` |
| 日志文件 | `/tmp/clash.log` |
| 监控日志 | `/tmp/clash-monitor.log` |

---

## 🔑 节点切换

### 切换到特定节点

```bash
# 先查看可用节点
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.all'

# 切换节点（示例：切换到美国节点）
curl -X PUT "http://127.0.0.1:9091/proxies/GLOBAL" \
  -H "Content-Type: application/json" \
  -d '{"name":"美国 A01 Youtube无广告 联通高带宽优化"}'
```

### 查看当前节点

```bash
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.now'
```

---

## 🛠️ 高级配置

### 自定义端口

编辑 `~/.config/clash/config.yaml`，修改以下配置：

```yaml
# HTTP 代理
port: 7890

# SOCKS5 代理
socks-port: 7891

# 外部控制接口
external-controller: 127.0.0.1:9091
```

### 配置 DNS

```yaml
dns:
  enable: true
  enhanced-mode: fake-ip
  nameserver:
    - 223.5.5.5
    - 114.114.114.114
  fallback:
    - https://1.1.1.1/dns-query
    - https://8.8.8.8/dns-query
```

### 配置规则

Clash 支持灵活的规则配置，详见：
- [Clash Meta 配置文档](https://wiki.metacubex.one/config/)
- [配置在线生成器](https://api.dler.io/)

---

## 🔍 故障排查

### 问题 1: 无法下载订阅配置

**解决方案:**

1. 检查订阅链接是否正确
2. 设置代理后重试：
   ```bash
   export http_proxy=http://127.0.0.1:7890
   export https_proxy=http://127.0.0.1:7890
   bash scripts/install.sh <订阅链接>
   ```

### 问题 2: Clash 启动失败

**查看日志:**
```bash
cat /tmp/clash.log
```

**常见原因:**
- 配置文件格式错误
- 端口被占用
- 订阅链接失效

### 问题 3: 代理无法访问外部网站

**检查:**
1. Clash 是否在运行：`bash scripts/clash.sh status`
2. 代理环境变量是否设置：`source scripts/proxy.sh status`
3. 节点是否有效：尝试切换其他节点

### 问题 4: OpenClaw 启动时 Clash 未启动

**检查:**
1. BOOT.md 是否包含启动命令
2. 脚本路径是否正确
3. 查看日志：`tail -f /tmp/clash-monitor.log`

---

## 📚 相关资源

- **Clash Meta Wiki**: https://wiki.metacubex.one/
- **GitHub Releases**: https://github.com/MetaCubeX/mihomo/releases
- **配置生成器**: https://api.dler.io/

---

## ✅ 安装检查清单

- [ ] Clash 二进制已安装到 `~/bin/clash`
- [ ] 配置文件已在 `~/.config/clash/config.yaml`
- [ ] `~/bin` 已添加到 PATH
- [ ] Clash 可以启动
- [ ] 代理环境变量可以启用
- [ ] 可以访问 Google 和 YouTube
- [ ] OpenClaw 启动钩子已配置（可选）
- [ ] Cron 监控已配置（可选）

---

**最后更新**: 2026-02-27
