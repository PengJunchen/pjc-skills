#!/bin/bash
# Clash 监控脚本
# 如果 Clash 进程不存在，则启动它
# 这个脚本可以用于 cron job 来定期检查并确保 Clash 始终运行
# 适配 Claude Code 和 OpenClaw 环境

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检测运行环境
detect_environment() {
    if [ -n "$OPENCLAW_HOME" ] || [ -d "$HOME/.openclaw" ]; then
        echo "openclaw"
    else
        echo "claude-code"
    fi
}

ENVIRONMENT=$(detect_environment)

CLASH_PID="$HOME/.config/clash/clash.pid"
CLASH_SCRIPT="$SCRIPT_DIR/clash.sh"
LOG_FILE="/tmp/clash-monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] --- Clash 监控检查 (环境: $ENVIRONMENT) ---" >> "$LOG_FILE"

# 节流：一天只记录一次检查通过
TODAY=$(date +%Y%m%d)
STATUS_FILE="/tmp/clash-monitor-status.txt"

# 检查 Clash 是否在运行
if pgrep -x clash > /dev/null 2>&1; then
    # Clash 正在运行
    PID=$(pgrep -x clash)

    # 检查是否今天已经记录过运行状态
    if [ -f "$STATUS_FILE" ] && grep -q "$TODAY:running" "$STATUS_FILE"; then
        # 今天已经记录过，不重复记录
        echo "[$TIMESTAMP] ✓ Clash 正在运行 (PID: $PID, 环境: $ENVIRONMENT)" > "$STATUS_FILE"
    else
        echo "[$TIMESTAMP] ✓ Clash 正在运行 (PID: $PID, 环境: $ENVIRONMENT)" >> "$LOG_FILE"
        echo "$TODAY:running" > "$STATUS_FILE"
    fi
else
    # Clash 未运行，启动它
    echo "[$TIMESTAMP] ✗ Clash 未运行，正在启动... (环境: $ENVIRONMENT)" >> "$LOG_FILE"

    # 清理状态文件，下次运行会重新记录
    echo "$TODAY:restarting" > "$STATUS_FILE"

    # 清理可能存在的旧 PID 文件
    if [ -f "$CLASH_PID" ]; then
        rm -f "$CLASH_PID"
    fi

    # 启动 Clash
    bash "$CLASH_SCRIPT" start >> "$LOG_FILE" 2>&1

    # 等待2秒后检查是否启动成功
    sleep 2

    if pgrep -x clash > /dev/null 2>&1; then
        NEW_PID=$(pgrep -x clash)
        echo "[$TIMESTAMP] ✓ Clash 启动成功 (PID: $NEW_PID, 环境: $ENVIRONMENT)" >> "$LOG_FILE"
    else
        echo "[$TIMESTAMP] ✗ Clash 启动失败 (环境: $ENVIRONMENT)" >> "$LOG_FILE"

        # 尝试直接启动（备用方案）
        if [ -f "$HOME/bin/clash" ]; then
            echo "[$TIMESTAMP] 尝试直接启动 Clash... (环境: $ENVIRONMENT)" >> "$LOG_FILE"
            cd ~/.config/clash
            nohup clash -d ~/.config/clash > /tmp/clash.log 2>&1 &
            echo $! > "$CLASH_PID"

            sleep 2

            if pgrep -x clash > /dev/null 2>&1; then
                echo "[$TIMESTAMP] ✓ Clash 直接启动成功 (环境: $ENVIRONMENT)" >> "$LOG_FILE"
            else
                echo "[$TIMESTAMP] ✗ Clash 直接启动也失败，请检查配置和日志 (环境: $ENVIRONMENT)" >> "$LOG_FILE"
            fi
        fi
    fi
fi

# 保留最近7天的日志
find "$LOG_FILE" -type f -mtime +7 -delete 2>/dev/null || true
