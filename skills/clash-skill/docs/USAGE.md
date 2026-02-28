# Clash 代理使用指南

---

## 🚀 快速开始

### 启动 Clash

```bash
# 在技能目录内执行
bash scripts/clash.sh start

# 或使用相对路径（从任意位置）
bash "$(dirname "$(realpath "$0")")/scripts/clash.sh" start
```

### 启用代理

```bash
# 在技能目录内执行
source scripts/proxy.sh

# 或使用相对路径（从任意位置）
source "$(dirname "$(realpath "$0")")/scripts/proxy.sh"
```

### 测试连接

```bash
curl -I https://www.google.com
```

---

## 📊 日常使用

### 方式 1: 环境变量方式（推荐）

#### 启用代理
```bash
# 在技能目录内执行
source scripts/proxy.sh

# 或使用相对路径（从任意位置）
source "$(dirname "$(realpath "$0")")/scripts/proxy.sh"
```

#### 禁用代理
```bash
# 在技能目录内执行
source scripts/proxy.sh off

# 或使用相对路径（从任意位置）
source "$(dirname "$(realpath "$0")")/scripts/proxy.sh" off
```

#### 查看状态
```bash
# 在技能目录内执行
source scripts/proxy.sh status

# 或使用相对路径（从任意位置）
source "$(dirname "$(realpath "$0")")/scripts/proxy.sh" status
```

#### 测试代理
```bash
test_proxy
```

---

### 方式 2: 单命令使用代理

#### curl
```bash
# 通过代理执行单个 curl 请求
curl --proxy http://127.0.0.1:7890 https://www.google.com

# 或使用完整路径
curl -x http://127.0.0.1:7890 https://www.google.com
```

#### git
```bash
# 临时设置代理
https_proxy=http://127.0.0.1:7890 git clone https://github.com/user/repo.git

# 检出大文件时推荐
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

#### wget
```bash
# 临时使用代理
http_proxy=http://127.0.0.1:7890 wget https://example.com/file.zip

# 或使用 proxy 参数
wget --proxy=on --proxy-user= --proxy-password= \
  -e "http_proxy=http://127.0.0.1:7890" \
  https://example.com/file.zip
```

#### npm
```bash
# 临时使用代理
http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 npm install

# 或配置 npm 使用代理
npm config set proxy http://127.0.0.1:7890
npm config set https-proxy http://127.0.0.1:7890
```

#### pip
```bash
# 临时使用代理
pip install --proxy http://127.0.0.1:7890 package_name

# 在配置文件中设置
pip config set global.proxy http://127.0.0.1:7890
```

---

### 方式 3: 永久启用代理（不推荐）

在 `~/.bashrc` 中添加：

```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7891
export ALL_PROXY=socks5://127.0.0.1:7891
```

**注意**: 这会让所有网络请求都走代理，可能影响访问国内网站。建议使用 `scripts/proxy.sh` 的方式手动切换。

---

## 🎯 Clash 进程管理

### 查看状态

```bash
# 在技能目录内执行
bash scripts/clash.sh status

# 或使用相对路径（从任意位置）
bash "$(dirname "$(realpath "$0")")/scripts/clash.sh" status
```

输出示例：
```
📊 Clash 状态: 运行中
  PID: 12345
  内存: 45MB
  CPU: 1.2%
  启动时间: Thu Jan 30 03:09:01 UTC 2025

📡 代理端口:
  HTTP:  127.0.0.1:7890
  SOCKS: 127.0.0.1:7891
  API:   127.0.0.1:9091

📝 最近日志 (最后5行):
time="2025-01-30T03:09:53+08:00" level=info msg="Start initial..."
```

### 停止 Clash

```bash
# 在技能目录内执行
bash scripts/clash.sh stop

# 或使用相对路径（从任意位置）
bash "$(dirname "$(realpath "$0")")/scripts/clash.sh" stop
```

### 重启 Clash

```bash
# 在技能目录内执行
bash scripts/clash.sh restart

# 或使用相对路径（从任意位置）
bash "$(dirname "$(realpath "$0")")/scripts/clash.sh" restart
```

---

## 🌍 节点切换

### 获取节点列表

```bash
# 查看所有可用节点
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.all[]'

# 查看当前节点
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.now'

# 查看完整的节点信息
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq
```

### 切换节点

```bash
# 切换到指定节点
curl -X PUT "http://127.0.0.1:9091/proxies/GLOBAL" \
  -H "Content-Type: application/json" \
  -d '{"name":"美国 A01 Youtube无广告 联通高带宽优化"}'
```

### 常用节点示例

| 节点类型 | 示例名称 |
|---------|---------|
| 日本 | 日本 01 东京 联通 |
| 美国 | 美国 A01 Youtube无广告 |
| 香港 | 香港 01 智能专线 |
| 台湾 | 台湾 01 高速 |
| 新加坡 | 新加坡 01 联通优化 |

---

## 🔧 配置查看和修改

### 查看配置

```bash
# 查看完整配置
cat ~/.config/clash/config.yaml

# 查看代理组
cat ~/.config/clash/config.yaml | grep -A 20 "proxy-groups:"
```

### 更新订阅

```bash
# 重新下载订阅配置（需要先设置代理）
# 在技能目录内执行
source scripts/proxy.sh
# 或使用相对路径（从任意位置）
source "$(dirname "$(realpath "$0")")/scripts/proxy.sh"

curl -o ~/.config/clash/config.yaml <订阅链接>

# 重启 Clash 应用新配置
# 在技能目录内执行
bash scripts/clash.sh restart
# 或使用相对路径（从任意位置）
bash "$(dirname "$(realpath "$0")")/scripts/clash.sh" restart
```

---

## 📊 监控和日志

### 查看日志

```bash
# 实时查看 Clash 日志
tail -f /tmp/clash.log

# 查看最近 50 行
tail -50 /tmp/clash.log

# 查看监控日志
tail -f /tmp/clash-monitor.log
```

### 监控连接

```bash
# 查看当前连接
curl "http://127.0.0.1:9091/connections" | jq

# 查看 Clash 流量统计
curl "http://127.0.0.1:9091/traffic" | jq
```

---

## 💡 使用技巧

### 1. 智能切换代理

创建一个别名快速切换：

```bash
# 添加到 ~/.bashrc
# 注意：需要根据实际技能目录位置调整路径
CLASH_SKILL_DIR="$(dirname "$(realpath "$0")")"
alias proxy-on="source \"$CLASH_SKILL_DIR/scripts/proxy.sh\""
alias proxy-off="source \"$CLASH_SKILL_DIR/scripts/proxy.sh\" off"
alias proxy-status="source \"$CLASH_SKILL_DIR/scripts/proxy.sh\" status"
alias clash-restart="bash \"$CLASH_SKILL_DIR/scripts/clash.sh\" restart"
```

### 2. 按 Ctrl+C 停止代理下载

如果正在通过代理下载文件，按 Ctrl+C 会停止下载，但不会禁用代理环境变量。

### 3. 测试不同节点

```bash
# 切换到日本节点
curl -X PUT "http://127.0.0.1:9091/proxies/GLOBAL" \
  -H "Content-Type: application/json" \
  -d '{"name":"日本 01 东京 联通"}'

# 测试速度
curl -o /dev/null -s -w "下载速度: %{speed_download} bytes/sec\n" \
  --proxy http://127.0.0.1:7890 \
  https://speed.cloudflare.com/__down?bytes=10000000
```

### 4. 代理测试脚本

```bash
#!/bin/bash
# 测试不同网站的访问

test_site() {
    local url=$1
    local name=$2

    if curl -I -s --connect-timeout 5 "$url" > /dev/null 2>&1; then
        echo "✓ $name"
    else
        echo "✗ $name"
    fi
}

echo "测试代理连接..."
test_site "https://www.google.com" "Google"
test_site "https://www.youtube.com" "YouTube"
test_site "https://github.com" "GitHub"
test_site "https://openai.com" "OpenAI"
test_site "https://twitter.com" "Twitter"
```

---

## 🔒 安全建议

1. **不要共享订阅链接** - 订阅链接包含你的账户信息
2. **定期更新** - 订阅链接可能有有效期，定期更新
3. **监控流量** - 注意流量使用，避免超出套餐限制
4. **使用 HTTPS** - 访问网站时优先使用 HTTPS

---

## 📚 相关资源

- **[安装指南](SETUP.md)** - 完整安装步骤
- **[故障排查](TROUBLESHOOTING.md)** - 常见问题解决
- **Clash Meta Wiki**: https://wiki.metacubex.one/

---

## ❓ 常见问题

### Q: 代理启用后无法访问国内网站？

A: 这是因为代理会拦截所有网络流量。可以：
- 使用 `source proxy.sh off` 临时禁用代理
- 配置 Clash 的分流规则（需要修改 `config.yaml`）

### Q: 如何知道代理是否在工作？

A: 运行 `test_proxy` 或访问 Google：
```bash
curl -I https://www.google.com
```

### Q: 代理速度很慢怎么办？

A: 尝试：
1. 切换到其他节点
2. 检查订阅服务商是否有流量限制
3. 重新下载订阅配置

### Q: 可以在多个终端同时使用代理吗？

A: 可以！因为代理环境变量是每个终端独立的。每个终端都需要执行 `source proxy.sh`。

---

**最后更新**: 2026-02-27
