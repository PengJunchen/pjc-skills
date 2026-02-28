#!/bin/bash
# pjc-skills OpenClaw Skills 安装脚本
# 将 skills 从项目目录安装到 OpenClaw skills 目录 (/app/skills)

set -e

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
PROJECT_DIR="$SCRIPT_DIR"

echo ""
echo "=========================================="
echo "  pjc-skills OpenClaw Skills 安装"
echo "=========================================="
echo ""

# 检查 OpenClaw skills 目录
log_step "检查 OpenClaw skills 目录..."

if [ ! -d "/app/skills" ]; then
    log_error "OpenClaw skills 目录不存在: /app/skills"
    exit 1
fi

log_info "OpenClaw skills 目录: /app/skills"

# 检查项目 skills 目录
log_step "检查项目 skills 目录..."

if [ ! -d "$PROJECT_DIR/skills" ]; then
    log_error "项目 skills 目录不存在: $PROJECT_DIR/skills"
    exit 1
fi

log_info "项目 skills 目录: $PROJECT_DIR/skills"

# 列出要安装的 skills
log_step "检查要安装的 skills..."

if ! ls -1 "$PROJECT_DIR/skills"/* >/dev/null 2>&1; then
    log_error "没有找到任何 skills"
    exit 1
fi

SKILLS_TO_INSTALL=($PROJECT_DIR/skills/*)
log_info "找到 ${#SKILLS_TO_INSTALL[@]} 个 skills:"
for skill in "${SKILLS_TO_INSTALL[@]}"; do
    skill_name=$(basename "$skill")
    echo "  - $skill_name"
done

# 安装每个 skill
log_step "开始安装 skills..."

for skill_dir in "${SKILLS_TO_INSTALL[@]}"; do
    skill_name=$(basename "$skill_dir")
    target_dir="/app/skills/$skill_name"

    log_info "正在安装: $skill_name"

    # 检查 skill 是否已存在
    if [ -d "$target_dir" ]; then
        # 备份已存在的 skill
        backup_dir="${target_dir}.backup.$(date +%Y%m%d%H%M%S)"
        log_warn "Skill 已存在，备份到: $backup_dir"
        mv "$target_dir" "$backup_dir"
    fi

    # 复制 skill
    cp -r "$skill_dir" "$target_dir"

    # 验证 SKILL.md 文件
    if [ ! -f "$target_dir/SKILL.md" ]; then
        log_warn "$skill_name 没有 SKILL.md，可能不是有效的 OpenClaw skill"
    fi

    # 设置脚本可执行权限
    if [ -d "$target_dir/scripts" ]; then
        find "$target_dir/scripts" -name "*.sh" -type f -exec chmod +x {} \;
        log_info "  - 设置 scripts 目录中 .sh 文件的可执行权限"
    fi

    # 设置 tools 目录脚本可执行权限
    if [ -d "$target_dir/tools" ]; then
        find "$target_dir/tools" -name "*.sh" -type f -exec chmod +x {} \;
        log_info "  - 设置 tools 目录中 .sh 文件的可执行权限"
    fi

    log_info "✓ 已安装: $skill_name"
done

# 安装完成
log_step "安装完成！"

echo ""
echo "=========================================="
log_info "Skills 安装成功！"
echo "=========================================="
echo ""
echo "📦 已安装的 skills:"
ls -1 /app/skills/$(basename "${SKILLS_TO_INSTALL[0]}") 2>/dev/null | while read skill_name; do
    if [ -d "/app/skills/$skill_name" ] && [ -f "/app/skills/$skill_name/SKILL.md" ]; then
        echo "  ✓ $skill_name"
    fi
done
echo ""

echo "📂 OpenClaw Skills 目录: /app/skills"
echo ""
echo "🚀 下一步操作:"
echo ""
echo "  1. 重启 OpenClaw 以加载新的 skills（如果需要）"
echo "  2. 或直接使用 skill："
echo "     查看可用 skills: openclaw skills list"
echo ""
echo "💡 提示: 已安装的 skills 会在 OpenClaw 识别时自动提示"
echo ""
