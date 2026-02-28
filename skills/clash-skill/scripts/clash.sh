#!/bin/bash
# Clash Meta 启动/停止脚本
# 使用方法:
#   ./clash.sh start   # 启动 Clash
#   ./clash.sh stop    # 停止 Clash
#   ./clash.sh restart # 重启 Clash
#   ./clash.sh status  # 查看状态
# 适配 Claude Code 和 OpenClaw 环境

# 获取脚本所在目录的父目录（clash-skill 目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# 检测运行环境
detect_environment() {
    if [ -n "$OPENCLAW_HOME" ] || [ -d "$HOME/.openclaw" ]; then
        echo "openclaw"
    else
        echo "claude-code"
    fi
}

ENVIRONMENT=$(detect_environment)

# 配置路径
CLASH_BIN="$HOME/bin/clash"
CLASH_DIR="$HOME/.config/clash"
CLASH_PID="$CLASH_DIR/clash.pid"
CLASH_LOG="/tmp/clash.log"

# 确保路径在 PATH 中
export PATH=$HOME/bin:$PATH

start_clash() {
    if [ -f "$CLASH_PID" ]; then
        PID=$(cat "$CLASH_PID")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "⚠️  Clash 已经在运行 (PID: $PID)"
            return 1
        else
            rm -f "$CLASH_PID"
        fi
    fi

    # 检查配置文件是否存在
    if [ ! -f "$CLASH_DIR/config.yaml" ]; then
        echo "✗ 配置文件不存在: $CLASH_DIR/config.yaml"
        echo ""
        echo "请先运行安装脚本:"
        echo "  bash $SCRIPT_DIR/install.sh <订阅链接>"
        return 1
    fi

    echo "🚀 启动 Clash Meta..."
    cd "$CLASH_DIR"
    nohup clash -d "$CLASH_DIR" > "$CLASH_LOG" 2>&1 &
    echo $! > "$CLASH_PID"

    sleep 2

    if ps -p $(cat "$CLASH_PID") > /dev/null 2>&1; then
        echo "✓ Clash 启动成功 (PID: $(cat $CLASH_PID))"
        echo "  HTTP 代理: http://127.0.0.1:7890"
        echo "  SOCKS 代理: socks5://127.0.0.1:7891"
        echo "  控制面板: http://127.0.0.1:9091"
        echo ""
        echo "📶 启用代理: source $SCRIPT_DIR/proxy.sh"
        
        # OpenClaw 环境提示
        if [ "$ENVIRONMENT" = "openclaw" ]; then
            echo ""
            echo "💡 OpenClaw 集成: 已在 BOOT.md 中配置自动启动"
        fi
    else
        echo "✗ Clash 启动失败，请查看日志: $CLASH_LOG"
        rm -f "$CLASH_PID"
        return 1
    fi
}

stop_clash() {
    if [ ! -f "$CLASH_PID" ]; then
        echo "⚠️  Clash 未运行"
        return 1
    fi

    PID=$(cat "$CLASH_PID")
    if ! ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  Clash 进程不存在，清理 PID 文件"
        rm -f "$CLASH_PID"
        return 1
    fi

    echo "⏹️  停止 Clash (PID: $PID)..."
    kill "$PID"

    # 等待进程结束
    for i in {1..10}; do
        if ! ps -p "$PID" > /dev/null 2>&1; then
            echo "✓ Clash 已停止"
            rm -f "$CLASH_PID"
            return 0
        fi
        sleep 1
    done

    echo "⚠️  Clash 未能正常停止，强制终止..."
    kill -9 "$PID"
    rm -f "$CLASH_PID"
    echo "✓ Clash 已强制停止"
}

restart_clash() {
    echo "🔄 重启 Clash..."
    stop_clash
    sleep 1
    start_clash
}

status_clash() {
    if [ ! -f "$CLASH_PID" ]; then
        echo "📊 Clash 状态: 未运行"
        return 1
    fi

    PID=$(cat "$CLASH_PID")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "📊 Clash 状态: 运行中"
        echo "  PID: $PID"
        echo "  内存: $(ps -p $PID -o rss= | awk '{print int($1/1024)"MB"}')"
        echo "  CPU: $(ps -p $PID -o %cpu=)%"
        echo "  启动时间: $(ps -p $PID -o lstart=)"
        echo "  环境: $ENVIRONMENT"
        echo ""
        echo "📡 代理端口:"
        echo "  HTTP:  127.0.0.1:7890"
        echo "  SOCKS: 127.0.0.1:7891"
        echo "  API:   127.0.0.1:9091"
        echo ""
        echo "📝 最近日志 (最后5行):"
        tail -5 "$CLASH_LOG" 2>/dev/null
    else
        echo "📊 Clash 状态: 僵尸进程 (PID文件存在但进程不存在)"
        rm -f "$CLASH_PID"
        return 1
    fi
}

# 主函数
case "$1" in
    start)
        start_clash
        ;;
    stop)
        stop_clash
        ;;
    restart)
        restart_clash
        ;;
    status)
        status_clash
        ;;
    *)
        echo "Clash Meta 控制脚本"
        echo ""
        echo "使用方法:"
        echo "  $0 start   启动 Clash"
        echo "  $0 stop    停止 Clash"
        echo "  $0 restart 重启 Clash"
        echo "  $0 status  查看状态"
        echo ""
        echo "配置文件: $CLASH_DIR/config.yaml"
        echo "日志文件: $CLASH_LOG"
        echo "技能目录: $SKILL_DIR"
        echo "运行环境: $ENVIRONMENT"
        ;;
esac
