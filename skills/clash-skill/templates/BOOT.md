# OpenClaw Boot Hook - Clash 自动启动

## 快速启动（推荐）

```bash
# 启动 Clash
bash clash-skill/scripts/clash.sh start

# 检查 Clash 状态
bash clash-skill/scripts/clash.sh status

# 运行诊断工具
bash clash-skill/tools/check-status.sh
```

## 高级路径配置

### 方式 1: 自动检测路径（兼容性最好）

```bash
# 自动检测 clash-skill 目录
if [ -f "clash-skill/scripts/clash.sh" ]; then
    bash clash-skill/scripts/clash.sh start
elif [ -f "$HOME/.openclaw/workspace/clash-skill/scripts/clash.sh" ]; then
    bash "$HOME/.openclaw/workspace/clash-skill/scripts/clash.sh" start
elif [ -f "/opt/openclaw/workspace/clash-skill/scripts/clash.sh" ]; then
    bash "/opt/openclaw/workspace/clash-skill/scripts/clash.sh" start
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BOOT] 错误: 找不到 clash-skill 目录" >> /tmp/boot.log
    exit 1
fi
```

### 方式 2: 绝对路径（明确指定）

```bash
bash /home/node/.openclaw/workspace/pjc-skills/skills/clash-skill/scripts/clash.sh start
```

## 高级启动策略

### 延迟启动（适合网络就绪较慢的环境）

```bash
# 等待 60 秒后启动（WSL2/容器推荐）
sleep 60
bash clash-skill/scripts/clash.sh start
```

### 重试机制（增加启动成功率）

```bash
MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BOOT] 尝试启动 Clash (第 $((RETRY_COUNT+1)) 次)..."
    bash clash-skill/scripts/clash.sh start
    
    if [ $? -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BOOT] Clash 启动成功"
        break
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BOOT] Clash 启动失败，等待 3 秒后重试..."
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep 3
    fi
done
```

## 多方案配置

### 方案 1: 使用 OpenClaw Gateway Hook（推荐）

```bash
# 复制 hook 配置
cp -r clash-skill/hooks/clash-startup ~/.openclaw/workspace/hooks/
```

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

### 方案 2: 使用 Cron（备选方案）

```bash
# 添加 crontab
(crontab -l 2>/dev/null; echo "@reboot sleep 60 && bash /home/node/.openclaw/workspace/pjc-skills/skills/clash-skill/scripts/clash.sh start >> /tmp/clash-cron.log 2>&1") | crontab -
```

## 故障排查

### 检查日志
```bash
cat /tmp/boot.log
cat /tmp/clash-startup.log
cat /tmp/clash-startup-debug.log
cat /tmp/clash.log
```

### 手动测试
```bash
bash clash-skill/scripts/clash.sh status
bash clash-skill/scripts/clash.sh start
```

### 检查配置
```bash
cat ~/.openclaw/openclaw.json | grep -A 10 hooks
```

## 路径说明

此 BOOT.md 文件应放置在 OpenClaw workspace 的根目录：
```
~/.openclaw/workspace/BOOT.md
```

clash-skill 应该相对于 workspace 根目录部署：
```
~/.openclaw/workspace/
├── BOOT.md
└── clash-skill/
    └── scripts/
        └── clash.sh
```

## 日志文件

- **Clash 日志**: `/tmp/clash.log`
- **Hook 日志**: `/tmp/boot.log`
- **Clash PID 文件**: `~/.config/clash/clash.pid`
- **Cron 日志**: `/tmp/clash-cron.log`

---

**Created for**: OpenClaw clash-skill
**Last updated**: 2026-02-28
