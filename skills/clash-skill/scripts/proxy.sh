#!/bin/bash
# 代理控制脚本
# 使用方法:
#   source proxy.sh        # 启用代理
#   source proxy.sh off    # 关闭代理
#   source proxy.sh status # 查看状态
# 适配 Claude Code 和 OpenClaw 环境

# 检测运行环境
detect_environment() {
    if [ -n "$OPENCLAW_HOME" ] || [ -d "$HOME/.openclaw" ]; then
        echo "openclaw"
    else
        echo "claude-code"
    fi
}

ENVIRONMENT=$(detect_environment)

PROXY_HTTP="http://127.0.0.1:7890"
PROXY_HTTPS="http://127.0.0.1:7890"
PROXY_SOCKS="socks5://127.0.0.1:7891"

if [ "$1" = "off" ]; then
    echo "🔴 关闭代理"
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset all_proxy
    unset ALL_PROXY
    echo "✓ 代理已禁用"
elif [ "$1" = "status" ]; then
    echo "📊 当前代理状态:"
    echo "  HTTP_PROXY: ${HTTP_PROXY:-未设置}"
    echo "  HTTPS_PROXY: ${HTTPS_PROXY:-未设置}"
    echo "  Clash 进程: $(pgrep -x clash 2>/dev/null | wc -l) 个运行中"
    echo "  运行环境: $ENVIRONMENT"
    if [ -n "$http_proxy" ]; then
        echo -e "\n🧪 测试连接..."
        if timeout 5 curl -I https://www.google.com >/dev/null 2>&1; then
            echo "  ✓ 代理正常工作"
        else
            echo "  ✗ 代理无法访问"
        fi
    else
        echo -e "\n⚠️  代理未启用"
    fi
else
    # 检查 Clash 是否在运行
    if ! pgrep -x clash > /dev/null 2>&1; then
        echo "⚠️  Clash 未运行，先启动 Clash:"
        echo "  bash $(dirname "$0")/clash.sh start"
        return 1
    fi

    echo "🟢 启用代理"
    export http_proxy=$PROXY_HTTP
    export https_proxy=$PROXY_HTTPS
    export HTTP_PROXY=$PROXY_HTTP
    export HTTPS_PROXY=$PROXY_HTTPS
    export all_proxy=$PROXY_SOCKS
    export ALL_PROXY=$PROXY_SOCKS
    echo "✓ 代理已启用"
    echo "  HTTP: $PROXY_HTTP"
    echo "  HTTPS: $PROXY_HTTPS"
    echo "  SOCKS5: $PROXY_SOCKS"
    echo "  环境: $ENVIRONMENT"
fi

# 测试代理的便捷函数
test_proxy() {
    if [ -z "$http_proxy" ]; then
        echo "⚠️  代理未启用，先运行: source proxy.sh"
        return 1
    fi
    echo "🧪 测试 Google..."
    if curl -I -s --connect-timeout 10 https://www.google.com >/dev/null 2>&1; then
        echo "  ✓ 可以访问 Google"
    else
        echo "  ✗ 无法访问 Google"
    fi

    echo "🧪 测试 YouTube..."
    if curl -I -s --connect-timeout 10 https://www.youtube.com >/dev/null 2>&1; then
        echo "  ✓ 可以访问 YouTube"
    else
        echo "  ✗ 无法访问 YouTube"
    fi

    echo "🧪 测试 GitHub..."
    if curl -I -s --connect-timeout 10 https://github.com >/dev/null 2>&1; then
        echo "  ✓ 可以访问 GitHub"
    else
        echo "  ✗ 无法访问 GitHub"
    fi
}
