#!/bin/bash
# 测试 Clash 自动启动设置

echo "=========================================="
echo "Clash 自动启动测试脚本"
echo "=========================================="
echo ""

echo "1. 检查 hook 目录结构..."
ls -la /home/node/.openclaw/workspace/hooks/clash-startup/
echo ""

echo "2. 检查配置文件中的 clash-startup hook是否已启用..."
grep -A 3 "clash-startup" ~/.openclaw/openclaw.json
echo ""

echo "3. 检查 hook 的 HOOK.md 文件..."
cat /home/node/.openclaw/workspace/hooks/clash-startup/HOOK.md | head -10
echo ""

echo "4. 检查冲突脚本是否存在..."
CLASH_SCRIPT="/home/node/.openclaw/workspace/pjc-skills/skills/clash-skill/scripts/clash.sh"
if [ -f "$CLASH_SCRIPT" ]; then
    echo "✓ Clash 脚本存在: $CLASH_SCRIPT"
else
    echo "✗ Clash 脚本不存在: $CLASH_SCRIPT"
    echo "  请检查 clash-skill 的安装路径"
fi
echo ""

echo "5. 检查 Clash 当前状态..."
if pgrep -f clash > /dev/null; then
    echo "✓ Clash 正在运行"
    pgrep -f clash | xargs ps -p
else
    echo "✗ Clash 未运行"
fi
echo ""

echo "6. 查看 clash-startup 日志..."
if [ -f "/tmp/clash-startup.log" ]; then
    echo "Log file exists, last entries:"
    tail -10 /tmp/clash-startup.log
else
    echo "Log file not found (hook has not been triggered yet, which is expected if gateway has not been restarted)"
fi
echo ""

echo "7. 查看 Clash 配置..."
if [ -f "$HOME/.config/clash/config.yaml" ]; then
    echo "✓ Clash 配置文件存在"
    echo "  配置文件: $HOME/.config/clash/config.yaml"
else
    echo "✗ Clash 配置文件不存在"
fi
echo ""

echo "=========================================="
echo "总结："
echo "- 自定义 hook 已创建: /home/node/.openclaw/workspace/hooks/clash-startup/"
echo "- 配置已更新: ~/.openclaw/openclaw.json"
echo "- 下次重启 Gateway 时，hook 会自动启动 Clash"
echo "- 所有日志将记录到: /tmp/clash-startup.log"
echo ""
echo "要立即测试 hook，可以手动触发（模拟 gateway:startup 事件）"
echo "或者重启 OpenClaw Gateway"
echo "=========================================="
