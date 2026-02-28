#!/bin/bash
# pjc-skills 一键安装和初始化脚本
# 适用于 OpenClaw

set -e

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "=========================================="
echo "  pjc-skills 一键安装和初始化"
echo "=========================================="
echo ""

# 检测环境
log_step "检测 OpenClaw 环境..."

# 检测是否在 OpenClaw 环境中
if [ -n "$OPENCLAW_HOME" ] || [ -d "$HOME/.openclaw" ]; then
    ENVIRONMENT="openclaw"
    log_info "检测到 OpenClaw 环境"
    
    # 确定 OpenClaw workspace 路径
    if [ -n "$OPENCLAW_WORKSPACE" ]; then
        WORKSPACE_DIR="$OPENCLAW_WORKSPACE"
    elif [ -f "$HOME/.openclaw/openclaw.json" ]; then
        WORKSPACE_DIR=$(grep -o '"workspace"[[:space:]]*:[[:space:]]*"[^"]*"' "$HOME/.openclaw/openclaw.json" | cut -d'"' -f4)
    else
        WORKSPACE_DIR="$HOME/.openclaw/workspace"
    fi
    
    log_info "Workspace 路径: $WORKSPACE_DIR"
else
    log_error "未检测到 OpenClaw 环境"
    log_info "请确保 OpenClaw 已安装并配置"
    log_info "OpenClaw 工作目录应为: $HOME/.openclaw/workspace"
    exit 1
fi

# 检查项目结构
log_step "检查项目结构..."

if [ ! -d "$PROJECT_DIR/skills" ]; then
    log_error "skills 目录不存在: $PROJECT_DIR/skills"
    exit 1
fi

log_info "项目结构检查通过"

# 初始化 clash-skill（如果需要）
log_step "初始化 clash-skill..."

CLASH_SKILL_DIR="$PROJECT_DIR/skills/clash-skill"

if [ -d "$CLASH_SKILL_DIR" ]; then
    log_info "clash-skill 已存在"
    
    # 检查是否需要安装 Clash
    if [ ! -f "$HOME/bin/clash" ]; then
        log_warn "Clash 未安装，需要运行安装脚本"
        echo ""
        echo "请运行以下命令安装 Clash:"
        echo "  cd $CLASH_SKILL_DIR"
        echo "  bash scripts/install.sh <订阅链接>"
        echo ""
    else
        log_info "Clash 已安装"
    fi
else
    log_warn "clash-skill 目录不存在"
fi

# 配置 OpenClaw 集成
if [ "$ENVIRONMENT" = "openclaw" ]; then
    log_step "配置 OpenClaw 集成..."
    
    # 检查 BOOT.md 文件
    BOOT_FILE="$WORKSPACE_DIR/BOOT.md"
    
    if [ -f "$BOOT_FILE" ]; then
        log_info "BOOT.md 已存在"
        
        # 检查是否已配置 clash-skill 启动
        if grep -q "clash-skill" "$BOOT_FILE"; then
            log_info "clash-skill 启动配置已存在"
        else
            log_warn "建议在 BOOT.md 中添加 clash-skill 启动配置"
            echo ""
            echo "在 $BOOT_FILE 中添加以下内容:"
            echo ""
            echo "# 启动 Clash 代理"
            echo "if [ -f \"clash-skill/scripts/clash.sh\" ]; then"
            echo "    bash clash-skill/scripts/clash.sh start"
            echo "fi"
            echo ""
        fi
    else
        log_info "BOOT.md 不存在，创建模板..."
        
        cat > "$BOOT_FILE" << 'EOF'
# pjc-skills OpenClaw 启动脚本

# 启动 Clash 代理（如果已安装）
if [ -f "clash-skill/scripts/clash.sh" ]; then
    echo "[$(date)] [BOOT] Starting Clash proxy..."
    bash clash-skill/scripts/clash.sh start
fi
EOF
        
        log_info "已创建 BOOT.md: $BOOT_FILE"
    fi
    
    # 检查 cron 配置
    CRON_FILE="$HOME/.openclaw/cron/jobs.json"
    
    if [ -f "$CRON_FILE" ]; then
        log_info "cron 配置已存在"
        
        # 检查是否已配置 clash-monitor
        if grep -q "clash-monitor" "$CRON_FILE"; then
            log_info "clash-monitor cron 任务已配置"
        else
            log_warn "建议在 cron 配置中添加 clash-monitor"
            echo ""
            echo "在 $CRON_FILE 中添加以下任务:"
            echo ""
            echo '{'
            echo '  "name": "clash-monitor",'
            echo '  "schedule": "* * * * *",'
            echo '  "command": "bash \"$HOME/.openclaw/workspace/clash-skill/scripts/clash-monitor.sh\"",'
            echo '  "description": "Monitor and restart Clash if not running",'
            echo '  "enabled": true'
            echo '}'
            echo ""
        fi
    else
        log_info "cron 配置目录不存在，跳过"
    fi
fi



# 显示安装摘要
echo ""
echo "=========================================="
log_info "安装和初始化完成！"
echo "=========================================="
echo ""
echo "📋 环境信息:"
echo "  环境: $ENVIRONMENT"
echo "  项目目录: $PROJECT_DIR"
echo "  Workspace: $WORKSPACE_DIR"
echo ""
echo "📦 已安装技能:"
echo "  - clash-skill (代理管理)"
echo ""
echo "🚀 下一步操作:"
echo ""
echo "  1. 安装 Clash (如果尚未安装):"
echo "     cd $CLASH_SKILL_DIR"
echo "     bash scripts/install.sh <订阅链接>"
echo ""
echo "  2. 启动 Clash:"
echo "     bash $CLASH_SKILL_DIR/scripts/clash.sh start"
echo ""
echo "  3. 启用代理:"
echo "     source $CLASH_SKILL_DIR/scripts/proxy.sh"
echo ""
echo "  4. 测试连接:"
echo "     curl -I https://www.google.com"
echo ""
echo "  5. 查看 BOOT.md 配置:"
echo "     cat $BOOT_FILE"
echo ""

echo "📚 文档资源:"
echo "  - 项目 README: $PROJECT_DIR/README.md"
echo "  - clash-skill 文档: $CLASH_SKILL_DIR/README.md"
echo "  - 安装指南: $CLASH_SKILL_DIR/docs/SETUP.md"
echo "  - 使用指南: $CLASH_SKILL_DIR/docs/USAGE.md"
echo "  - 故障排查: $CLASH_SKILL_DIR/docs/TROUBLESHOOTING.md"
echo ""
echo "✅ 安装完成！"
echo ""
