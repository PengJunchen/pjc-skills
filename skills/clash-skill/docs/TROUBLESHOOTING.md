# Clash 故障排查指南

---

## 🔍 常见问题诊断流程

```
问题发生
    ↓
Clash 是否在运行? → 否 → 启动 Clash
    ↓ 是
代理环境变量是否设置? → 否 → source proxy.sh
    ↓ 是
节点是否有效? → 否 → 切换节点
    ↓ 是
网络是否有问题? → 检查防火墙/DNS
```

---

## 🚨 问题 1: Clash 无法启动

### 症状
```bash
bash scripts/clash.sh start
# 输出: ✗ Clash 启动失败...
```

### 可能原因和解决方案

#### 原因 1: 配置文件不存在或格式错误

**检查:**
```bash
ls -lh ~/.config/clash/config.yaml
```

**解决:**
```bash
# 重新下载订阅配置
source scripts/proxy.sh  # 启用代理
curl -o ~/.config/clash/config.yaml <订阅链接>

# 验证配置文件
cat ~/.config/clash/config.yaml | head -20
```

#### 原因 2: 端口被占用

**检查:**
```bash
# 检查 7890 端口
lsof -i:7890 2>/dev/null || netstat -tuln | grep 7890

# 检查 9091 端口
lsof -i:9091 2>/dev/null || netstat -tuln | grep 9091
```

**解决:**
```bash
# 停止占用端口的进程
# 方法 1: 查看并杀死进程
lsof -ti:7890 | xargs kill -9

# 方法 2: 停止并重启 Clash
bash scripts/clash.sh restart
```

#### 原因 3: 二进制文件不可执行

**检查:**
```bash
ls -lh ~/bin/clash
file ~/bin/clash
```

**解决:**
```bash
chmod +x ~/bin/clash

# 如果二进制下载失败，重新下载
cd /tmp
rm -f clash*
curl -L -o clash.gz https://github.com/MetaCubeX/mihomo/releases/download/v1.18.10/mihomo-linux-amd64-v1.18.10.gz
gunzip clash.gz
mv clash ~/bin/clash
chmod +x ~/bin/clash
```

#### 原因 4: Clash 二进制架构不匹配

**检查:**
```bash
# 检查系统架构
uname -m

# 查看 Clash 支持的架构
file ~/bin/clash
```

**解决:**
对于 ARM64 系统，下载对应的二进制：

```bash
cd /tmp
curl -L -o clash.gz https://github.com/MetaCubeX/mihomo/releases/download/v1.18.10/mihomo-linux-arm64-v1.18.10.gz
gunzip clash.gz
mv clash ~/bin/clash
chmod +x ~/bin/clash
```

---

## 🚨 问题 2: 代理无法访问外部网站

### 症状
```bash
curl -I https://www.google.com
# 输出: curl: (7) Failed to connect to 127.0.0.1 port 7890
```

### 可能原因和解决方案

#### 原因 1: 代理环境变量未设置

**检查:**
```bash
echo $http_proxy
echo $https_proxy
```

**解决:**
```bash
source scripts/proxy.sh
# 或
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0:1:7890
```

#### 原因 2: Clash 进程未运行

**检查:**
```bash
bash scripts/clash.sh status
# 或
pgrep -x clash
```

**解决:**
```bash
bash scripts/clash.sh start
```

#### 原因 3: 节点失效或被墙

**检查:**
```bash
# 查看日志是否有错误
tail -50 /tmp/clash.log | grep -i error

# 查看当前节点
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.now'
```

**解决:**
```bash
# 切换到其他节点
curl -X PUT "http://127.0.0.1:9091/proxies/GLOBAL" \
  -H "Content-Type: application/json" \
  -d '{"name":"日本 01 东京 联通"}'

# 或重新下载订阅配置
source scripts/proxy.sh
curl -o ~/.config/clash/config.yaml <订阅链接>
bash scripts/clash.sh restart
```

#### 原因 4: 防火墙拦截

**检查:**
```bash
# 如果使用 ufw
sudo ufw status

# 如果使用 iptables
sudo iptables -L -n
```

**解决:**
```bash
# 允许本地端口
sudo ufw allow 7890/tcp
sudo ufw allow 9091/tcp
```

---

## 🚨 问题 3: OpenClaw 启动时 Clash 未自动启动

### 症状
重启后需要手动启动 Clash。

### 可能原因和解决方案

#### 原因 1: BOOT.md 未配置或路径错误

**检查:**
```bash
# 检查 OpenClaw 启动脚本文件
# 常见位置：~/.openclaw/workspace/BOOT.md
cat ~/.openclaw/workspace/BOOT.md

# 或检查 BOOT.md 脚本相对的 clash-skill 路径
ls -lh ~/.openclaw/workspace/clash-skill/scripts/clash.sh
```

**解决:**
在 OpenClaw 的启动脚本文件中添加以下任一方式：

**方式 1: 相对路径（推荐 - 当 clash-skill 在 workspace 根目录下）**

文件：`~/.openclaw/workspace/BOOT.md`

```bash
# 启动 Clash（相对路径）
bash clash-skill/scripts/clash.sh start
```

**方式 2: 自动检测路径（最灵活）**

文件：`~/.openclaw/workspace/BOOT.md`

```bash
# 自动检测并启动
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

#### 原因 2: boot-md hook 未启用

**检查:**
```bash
openclaw hooks list
```

**解决:**
```bash
openclaw hooks enable boot-md
```

#### 原因 3: Cron 监控未配置或路径错误

**检查:**
```bash
# 检查 OpenClaw Cron 配置文件
# 常见位置：~/.openclaw/cron/jobs.json
cat ~/.openclaw/cron/jobs.json

# 检查脚本路径是否存在
ls -lh ~/.openclaw/workspace/clash-skill/scripts/clash-monitor.sh
```

**解决:**
在 OpenClaw 的 Cron 配置文件中添加：

**重要**: Cron 任务必须使用绝对路径（或可解析的环境变量）

文件：`~/.openclaw/cron/jobs.json`

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

**注意**: 将 `$HOME` 替换为你的实际 home 目录（如 `/home/yourname`）。

---

## 🚨 问题 4: 订阅链接无法下载

### 症状
```bash
bash scripts/install.sh <订阅链接>
# 输出: ✗ 无法下载订阅配置
```

### 可能原因和解决方案

#### 原因 1: 网络无法访问订阅服务器

**检查:**
```bash
# 测试能否访问订阅服务器
curl -I <订阅链接>
```

**解决:**
如果可以访问国外网络，直接下载：
```bash
curl -o ~/.config/clash/config.yaml <订阅链接>
```

如果无法直接访问，需要通过代理下载：
```bash
# 先启用代理
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# 下载订阅
bash scripts/install.sh <订阅链接>
```

#### 原因 2: 订阅链接已过期或失效

**检查:**
登录订阅服务商网站查看订阅有效期。

**解决:**
向服务商续订或获取新的订阅链接。

---

## 🚨 问题 5: 代理速度很慢

### 症状
通过代理访问网站速度明显变慢。

### 可能原因和解决方案

#### 原因 1: 节点拥堵

**检查:**
```bash
# 查看当前节点
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.now'
```

**解决:**
切换到其他节点：
```bash
# 获取所有节点列表
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.all[]'

# 切换到其他节点
curl -X PUT "http://127.0.0.1:9091/proxies/GLOBAL" \
  -H "Content-Type: application/json" \
  -d '{"name":"新节点名称"}'
```

#### 原因 2: 流量套餐用尽

**检查:**
登录订阅服务商网站查看剩余流量。

**解决:**
升级套餐或等待下一次流量重置。

#### 原因 3: DNS 解析慢

**解决:**
修改 `~/.config/clash/config.yaml` 中的 DNS 配置：
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

然后重启 Clash：
```bash
bash scripts/clash.sh restart
```

---

## 🔧 诊断命令汇总

### 基本检查

```bash
# 1. 检查 Clash 进程
bash scripts/clash.sh status

# 2. 检查代理环境变量
source scripts/proxy.sh status

# 3. 测试代理连接
test_proxy

# 4. 查看日志
tail -50 /tmp/clash.log

# 5. 查看监控日志
tail -50 /tmp/clash-monitor.log
```

### 网络诊断

```bash
# 测试 Clash 端口
nc -zv 127.0.0.1 7890
nc -zv 127.0.0.1 9091

# 查看端口占用
lsof -i:7890
lsof -i:9091

# 测试 DNS 解析
nslookup www.google.com
dig @127.0.0.1 www.google.com
```

### 配置诊断

```bash
# 验证配置文件语法
clash -t -d ~/.config/clash

# 查看当前节点
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.now'

# 查看所有节点
curl "http://127.0.0.1:9091/proxies/GLOBAL" | jq '.all[]'

# 查看连接状态
curl "http://127.0.0.1:9091/connections" | jq
```

---

## 📞 获取帮助

如果以上方法都无法解决问题：

1. **查看日志文件**
   - `/tmp/clash.log` - Clash 运行日志
   - `/tmp/clash-monitor.log` - 监控脚本日志

2. **检查订阅服务商状态**
   - 订阅是否过期
   - 节点是否可用
   - 是否有公告

3. **参考官方文档**
   - [Clash Meta Wiki](https://wiki.metacubex.one/)
   - [Mihomo GitHub Issues](https://github.com/MetaCubeX/mihomo/issues)

4. **重新安装**
   ```bash
   # 停止 Clash
   bash scripts/clash.sh stop

   # 删除配置和二进制
   rm -rf ~/bin/clash ~/.config/clash

   # 重新运行安装
   bash scripts/install.sh <订阅链接>
   ```

---

## 📋 问题检查清单

故障排查时，按以下顺序检查：

- [ ] Clash 进程是否运行 (`pgrep -x clash`)
- [ ] 代理环境变量是否设置 (`echo $http_proxy`)
- [ ] 配置文件是否存在 (`ls ~/.config/clash/config.yaml`)
- [ ] 端口是否正常监听 (`lsof -i:7890`)
- [ ] 当前节点是否有效
- [ ] 网络连接是否正常 (ping, curl)
- [ ] 日志中是否有错误信息
- [ ] 防火墙是否拦截

---

**最后更新**: 2026-02-27
