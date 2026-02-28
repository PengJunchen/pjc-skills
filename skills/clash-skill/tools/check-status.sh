#!/bin/bash

echo "=========================================="
echo "Clash Hook 状态检查"
echo "=========================================="
echo ""

GATEWAY_PID=$(pgrep -f "openclaw-gateway" | head -1)
if [ -z "$GATEWAY_PID" ]; then
    echo "❌ Gateway 进程未找到（可能未启动）"
else
    echo "✅ Gateway 进程运行中 (PID: $GATEWAY_PID)"
    echo "   启动时间: $(ps -p $GATEWAY_PID -o lstart=)"
fi
echo ""

echo "=== Clash 进程状态 ==="
CLASH_PID=$(pgrep -x clash 2>/dev/null)
if [ -z "$CLASH_PID" ]; then
    echo "❌ Clash 进程未运行"
else
    echo "✅ Clash 进程运行中 (PID: $CLASH_PID)"
    echo "   启动时间: $(ps -p $CLASH_PID -o lstart=)"
fi
echo ""

echo "=== Hook 日志 ==="
if [ ! -f /tmp/clash-startup-debug.log ]; then
    echo "❌ Debug 日志文件不存在: /tmp/clash-startup-debug.log"
    echo "   这意味着 hook 从未被触发"
else
    echo "✅ Debug 日志文件存在"
    echo ""
    echo "最后更新时间: $(stat -c %y /tmp/clash-startup-debug.log)"
    echo ""
    echo "最近的 hook 触发记录:"
    echo "---"
    grep "Clash startup hook triggered" /tmp/clash-startup-debug.log | tail -3
    echo "---"
fi
echo ""

if [ ! -f /tmp/clash-startup.log ]; then
    echo "❌ 主日志文件不存在: /tmp/clash-startup.log"
else
    echo "✅ 主日志文件存在"
    echo "最后 5 行:"
    tail -5 /tmp/clash-startup.log | sed 's/^/  /'
fi
echo ""

echo "=== Hook 文件 ==="
HOOK_DIR="/home/node/.openclaw/workspace/hooks/clash-startup"
if [ -d "$HOOK_DIR" ]; then
    echo "✅ Hook 目录存在: $HOOK_DIR"
    echo ""
    echo "文件列表:"
    ls -lh "$HOOK_DIR" | tail -n +2 | sed 's/^/  /'
    echo ""
    if [ -f "$HOOK_DIR/HOOK.md" ]; then
        echo "✅ HOOK.md 存在"
        grep "events:" "$HOOK_DIR/HOOK.md" | sed 's/^/  /'
    else
        echo "❌ HOOK.md 不存在"
    fi
else
    echo "❌ Hook 目录不存在: $HOOK_DIR"
fi
echo ""

echo "=== 配置文件 ==="
grep -A 2 "clash-startup" /home/node/.openclaw/openclaw.json | sed 's/^/  /'
echo ""

echo "=========================================="
echo "建议的下一步："
echo "1. 检查 Gateway 日志，确认 hooks 是否被加载"
echo "2. 重启 Gateway，观察 /tmp/clash-startup-debug.log"
echo "3. 如果 hook 仍未触发，可能需要检查 OpenClaw 代码"
echo "=========================================="
