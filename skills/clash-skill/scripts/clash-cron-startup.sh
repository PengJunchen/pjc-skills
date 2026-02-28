#!/bin/bash
# Clash 启动脚本 - 用于 Cron @reboot 任务
#
# 此脚本用于在系统启动时自动启动 Clash 代理
#
# 使用方法：
# 1. 将此脚本复制到 clash-skill/scripts/ 目录
# 2. 添加到 crontab:
#    (crontab -l 2>/dev/null; echo "@reboot sleep 60 && /path/to/clash-cron-startup.sh >> /tmp/clash-cron.log 2>&1") | crontab -
#
# 注意：
# - 使用绝对路径
# - 睡眠60秒是为了等待系统服务完全启动
# - 日志输出到 /tmp/clash-cron.log

set -e

# 配置
CLASH_SCRIPT_DIR="/home/node/.openclaw/workspace/pjc-skills/skills/clash-skill/scripts"
CLASH_SCRIPT="$CLASH_SCRIPT_DIR/clash.sh"
LOG_FILE="/tmp/clash-cron.log"
SLEEP_TIME=60

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [clash-cron] $*" >> "$LOG_FILE"
}

# 主逻辑
main() {
    log "Starting Clash startup sequence..."

    # 等待系统启动完成
    log "Waiting ${SLEEP_TIME} seconds for system to boot..."
    sleep "$SLEEP_TIME"

    # 检查脚本是否存在
    if [ ! -f "$CLASH_SCRIPT" ]; then
        log "ERROR: Clash script not found at $CLASH_SCRIPT"
        exit 1
    fi

    # 检查是否已在运行
    if bash "$CLASH_SCRIPT" status > /dev/null 2>&1; then
        log "Clash is already running, skipping..."
        exit 0
    fi

    # 尝试启动 Clash
    log "Starting Clash..."
    if bash "$CLASH_SCRIPT" start >> "$LOG_FILE" 2>&1; then
        log "SUCCESS: Clash started successfully"

        # 验证启动
        sleep 3
        if bash "$CLASH_SCRIPT" status > /dev/null 2>&1; then
            log "VERIFIED: Clash is running"
        else
            log "WARNING: Clash started but verification failed"
        fi
    else
        log "ERROR: Failed to start Clash"
        exit 1
    fi
}

# 执行
main
