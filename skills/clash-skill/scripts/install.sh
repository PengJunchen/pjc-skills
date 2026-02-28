#!/bin/bash
# Clash 自动安装脚本
# 使用方法: bash install.sh <订阅链接>
# 适配 Claude Code 和 OpenClaw 环境

set -e

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检测运行环境
detect_environment() {
    if [ -n "$OPENCLAW_HOME" ] || [ -d "$HOME/.openclaw" ]; then
        echo "openclaw"
    else
        echo "claude-code"
    fi
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT=$(detect_environment)

echo ""
echo "=========================================="
echo "  Clash 安装脚本"
echo "  环境: $ENVIRONMENT"
echo "=========================================="
echo ""

# 检查参数
if [ -z "$1" ]; then
    log_error "请提供订阅链接"
    echo ""
    echo "使用方法:"
    echo "  bash install.sh <订阅链接>"
    echo ""
    echo "示例:"
    echo "  bash install.sh https://example.com/sub/your-token"
    echo ""
    exit 1
fi

SUBSCRIPTION_URL="$1"

# 检查是否在正确的环境中
if [ "$ENVIRONMENT" = "claude-code" ]; then
    log_warn "检测到 Claude Code 环境"
    log_info "Clash 技能主要针对 Linux 系统（Ubuntu/Debian/WSL2）"
    log_info "在 Windows 上，建议使用 WSL2 运行此脚本"
    echo ""
    read -p "是否继续安装? [y/N]: " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "安装已取消"
        exit 0
    fi
fi

# 检查是否已安装
CLASH_BIN="$HOME/bin/clash"
if [ -f "$CLASH_BIN" ]; then
    log_warn "Clash 已安装在 $CLASH_BIN"
    echo -n "是否重新安装? [y/N]: "
    read -r REINSTALL
    if [[ ! "$REINSTALL" =~ ^[Yy]$ ]]; then
        log_info "跳过安装，继续配置..."
    else
        log_info "重新安装 Clash..."
        rm -f "$CLASH_BIN"
    fi
fi

# 如果需要安装 Clash
if [ ! -f "$CLASH_BIN" ]; then
    log_step "正在下载 Clash Meta (Mihomo)..."

    # 检测架构
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            CLASH_URL="https://github.com/MetaCubeX/mihomo/releases/download/v1.18.10/mihomo-linux-amd64-v1.18.10.gz"
            ;;
        aarch64|arm64)
            CLASH_URL="https://github.com/MetaCubeX/mihomo/releases/download/v1.18.10/mihomo-linux-arm64-v1.18.10.gz"
            ;;
        *)
            log_error "不支持的架构: $ARCH"
            log_info "请手动下载 Clash Meta: https://github.com/MetaCubeX/mihomo/releases"
            exit 1
            ;;
    esac

    # 创建 bin 目录
    mkdir -p "$HOME/bin"

    # 下载 Clash
    log_info "从 $CLASH_URL 下载..."
    cd /tmp

    # 尝试使用代理下载（如果可用）
    if [ -n "$http_proxy" ] || [ -n "$https_proxy" ]; then
        log_info "检测到代理，使用代理下载..."
        curl -L -o clash.gz "$CLASH_URL"
    else
        # 尝试直接下载
        if curl -L -o clash.gz "$CLASH_URL" 2>/dev/null; then
            log_info "直接下载成功"
        else
            log_warn "直接下载失败，请确保网络可访问 GitHub"
            log_info "提示: 可以设置代理后重试:"
            log_info "  export http_proxy=http://127.0.0.1:7890"
            log_info "  export https_proxy=http://127.0.0.1:7890"
            log_info "  bash $0 $SUBSCRIPTION_URL"
            exit 1
        fi
    fi

    # 解压
    log_info "解压文件..."
    gunzip -c clash.gz > "$CLASH_BIN"
    chmod +x "$CLASH_BIN"
    rm -f clash.gz

    log_info "Clash 安装完成: $CLASH_BIN"

    # 创建 config 目录
    mkdir -p "$HOME/.config/clash"
else
    log_info "检测到 Clash 已安装，跳过下载"
fi

# 配置订阅链接
log_step "配置 Clash 订阅链接..."

CONFIG_FILE="$HOME/.config/clash/config.yaml"

# 启用代理以访问订阅链接
log_info "尝试下载订阅配置..."

# 尝试多种方式下载订阅
SUBSCRIPTION_DOWNLOADED=false

# 方式 1: 使用现有代理
if [ -n "$http_proxy" ] || [ -n "$https_proxy" ]; then
    log_info "使用代理下载订阅配置..."
    if curl -L -o "$CONFIG_FILE" "$SUBSCRIPTION_URL" 2>/dev/null; then
        SUBSCRIPTION_DOWNLOADED=true
    fi
fi

# 方式 2: 尝试直接下载
if [ "$SUBSCRIPTION_DOWNLOADED" = false ]; then
    log_info "尝试直接下载订阅配置..."
    if curl -L -o "$CONFIG_FILE" "$SUBSCRIPTION_URL" 2>/dev/null; then
        SUBSCRIPTION_DOWNLOADED=true
    fi
fi

if [ "$SUBSCRIPTION_DOWNLOADED" = false ]; then
    log_error "无法下载订阅配置"
    log_info "建议:"
    log_info "  1. 检查订阅链接是否正确"
    log_info "  2. 尝试使用代理:"
    log_info "     export http_proxy=http://127.0.0.1:7890"
    log_info "     export https_proxy=http://127.0.0.1:7890"
    log_info "  3. 手动下载配置文件到 $CONFIG_FILE"
    exit 1
fi

log_info "订阅配置下载完成"

# 验证配置文件
if [ ! -s "$CONFIG_FILE" ]; then
    log_error "配置文件为空或下载失败"
    exit 1
fi

# 配置外部控制（增强配置）
log_step "配置 Clash 外部控制..."

# 检查是否已有 external-controller 配置
if ! grep -q "external-controller:" "$CONFIG_FILE"; then
    # 添加外部控制配置
    cat >> "$CONFIG_FILE" << 'EOF'

# 外部控制配置
external-controller: 127.0.0.1:9091
external-ui: ui
secret: ""
EOF
    log_info "已添加外部控制配置"
else
    log_info "外部控制配置已存在，跳过"
fi

# 设置 PATH
if ! grep -q "$HOME/bin" ~/.bashrc; then
    log_info "添加 ~/bin 到 PATH..."
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
    log_info "请运行: source ~/.bashrc"
else
    log_info "PATH 已配置"
fi

# 验证安装
log_step "验证安装..."

# 检查版本
if command -v clash &> /dev/null; then
    CLASH_VERSION=$(clash -v 2>/dev/null || echo "unknown")
    log_info "Clash 版本: $CLASH_VERSION"
else
    log_warn "Clash 不在 PATH 中，请运行: source ~/.bashrc"
fi

# 检查配置文件
if [ -f "$CONFIG_FILE" ]; then
    CONFIG_SIZE=$(ls -lh "$CONFIG_FILE" | awk '{print $5}')
    log_info "配置文件: $CONFIG_FILE (大小: $CONFIG_SIZE)"

    # 显示节点数量（如果可能）
    if grep -q "proxies:" "$CONFIG_FILE"; then
        PROXY_COUNT=$(grep -A 5000 "proxies:" "$CONFIG_FILE" | grep "name:" | wc -l)
        if [ "$PROXY_COUNT" -gt 0 ]; then
            log_info "检测到 $PROXY_COUNT 个代理节点"
        fi
    fi
fi

# OpenClaw 集成提示
if [ "$ENVIRONMENT" = "openclaw" ]; then
    echo ""
    log_step "OpenClaw 集成提示:"
    log_info "建议在 BOOT.md 中添加自动启动配置"
    log_info "建议在 cron 中添加监控任务"
    echo ""
    log_info "查看集成模板:"
    log_info "  cat $SKILL_DIR/templates/BOOT.md.example"
    log_info "  cat $SKILL_DIR/templates/cron-jobs.json.example"
fi

echo ""
echo "=========================================="
log_info "Clash 安装完成！"
echo "=========================================="
echo ""
echo "📋 配置信息:"
echo "  配置文件: $CONFIG_FILE"
echo "  HTTP 代理: http://127.0.0.1:7890"
echo "  SOCKS5:     socks5://127.0.0.1:7891"
echo "  控制面板:   http://127.0.0.1:9091"
echo ""
echo "🚀 下一步操作:"
echo "  1. 启动 Clash:"
echo "     bash $SCRIPT_DIR/clash.sh start"
echo ""
echo "  2. 启用代理:"
echo "     source $SCRIPT_DIR/proxy.sh"
echo ""
echo "  3. 测试连接:"
echo "     curl -I https://www.google.com"
echo ""
echo "  4. 查看详细文档:"
echo "     cat $SKILL_DIR/docs/SETUP.md"
echo ""
