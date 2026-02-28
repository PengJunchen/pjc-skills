#!/bin/bash
# Clash Skill 验证脚本
# 验证 skill 的完整性和功能

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SUCCESS_COUNT=0
FAIL_COUNT=0

check_true() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}✗${NC} $1"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

check_false() {
    if [ $? -ne 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}✗${NC} $1"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

file_exists() {
    [ -f "$1" ]
}

dir_exists() {
    [ -d "$1" ]
}

echo ""
echo "=========================================="
echo "  Clash Skill 验证"
echo "=========================================="
echo ""

echo -e "${BLUE}[检查 1/10]${NC} 基础文件存在性"
echo "----------------------------------------"
file_exists "/app/skills/clash-skill/SKILL.md" && check_true "SKILL.md 存在" || check_false "SKILL.md 存在"
file_exists "/app/skills/clash-skill/README.md" && check_true "README.md 存在" || check_false "README.md 存在"
echo ""

echo -e "${BLUE}[检查 2/10]${NC} 文档文件"
echo "----------------------------------------"
file_exists "/app/skills/clash-skill/CLASH_AUTO_STARTUP_COMPLETE.md" && check_true "完整解决方案文档存在" || check_false "完整解决方案文档存在"
file_exists "/app/skills/clash-skill/CLASH_AUTO_STARTUP_HISTORY.md" && check_true "历史记录文档存在" || check_false "历史记录文档存在"
file_exists "/app/skills/clash-skill/docs/SETUP.md" && check_true "SETUP.md 存在" || check_false "SETUP.md 存在"
file_exists "/app/skills/clash-skill/docs/USAGE.md" && check_true "USAGE.md 存在" || check_false "USAGE.md 存在"
echo ""

echo -e "${BLUE}[检查 3/10]${NC} 脚本目录"
echo "----------------------------------------"
dir_exists "/app/skills/clash-skill/scripts" && check_true "scripts 目录存在" || check_false "scripts 目录存在"
file_exists "/app/skills/clash-skill/scripts/clash.sh" && check_true "clash.sh 存在" || check_false "clash.sh 存在"
file_exists "/app/skills/clash-skill/scripts/clash-monitor.sh" && check_true "clash-monitor.sh 存在" || check_false "clash-monitor.sh 存在"
file_exists "/app/skills/clash-skill/scripts/clash-cron-startup.sh" && check_true "clash-cron-startup.sh 存在" || check_false "clash-cron-startup.sh 存在"
file_exists "/app/skills/clash-skill/scripts/install.sh" && check_true "install.sh 存在" || check_false "install.sh 存在"
file_exists "/app/skills/clash-skill/scripts/proxy.sh" && check_true "proxy.sh 存在" || check_false "proxy.sh 存在"
echo ""

echo -e "${BLUE}[检查 4/10]${NC} 工具目录"
echo "----------------------------------------"
dir_exists "/app/skills/clash-skill/tools" && check_true "tools 目录存在" || check_false "tools 目录存在"
file_exists "/app/skills/clash-skill/tools/check-status.sh" && check_true "check-status.sh 存在" || check_false "check-status.sh 存在"
echo ""

echo -e "${BLUE}[检查 5/10]${NC} Hooks 目录"
echo "----------------------------------------"
dir_exists "/app/skills/clash-skill/hooks" && check_true "hooks 目录存在" || check_false "hooks 目录存在"
dir_exists "/app/skills/clash-skill/hooks/clash-startup" && check_true "clash-startup hook 存在" || check_false "clash-startup hook 存在"
file_exists "/app/skills/clash-skill/hooks/clash-startup/HOOK.md" && check_true "HOOK.md 存在" || check_false "HOOK.md 存在"
file_exists "/app/skills/clash-skill/hooks/clash-startup/handler.js" && check_true "handler.js 存在" || check_false "handler.js 存在"
echo ""

echo -e "${BLUE}[检查 6/10]${NC} 模板文件"
echo "----------------------------------------"
dir_exists "/app/skills/clash-skill/templates" && check_true "templates 目录存在" || check_false "templates 目录存在"
file_exists "/app/skills/clash-skill/templates/BOOT.md" && check_true "BOOT.md 模板存在" || check_false "BOOT.md 模板存在"
echo ""

echo -e "${BLUE}[检查 7/10]${NC} 脚本可执行权限"
echo "----------------------------------------"
[ -x "/app/skills/clash-skill/scripts/clash.sh" ] && check_true "clash.sh 可执行" || check_false "clash.sh 可执行"
[ -x "/app/skills/clash-skill/scripts/clash-monitor.sh" ] && check_true "clash-monitor.sh 可执行" || check_false "clash-monitor.sh 可执行"
[ -x "/app/skills/clash-skill/scripts/clash-cron-startup.sh" ] && check_true "clash-cron-startup.sh 可执行" || check_false "clash-cron-startup.sh 可执行"
[ -x "/app/skills/clash-skill/tools/check-status.sh" ] && check_true "check-status.sh 可执行" || check_false "check-status.sh 可执行"
echo ""

echo -e "${BLUE}[检查 8/10]${NC} Git 仓库（如果在 git 中）"
echo "----------------------------------------"
if [ -d "/app/skills/clash-skill/.git" ]; then
    check_true "Git 仓库存在"
    cd /app/skills/clash-skill 2>/dev/null && git status >/dev/null 2>&1 && check_true "Git 仓库可用" || check_false "Git 仓库可用"
else
    echo -e "${YELLOW}⊜${NC} 不在 git 仓库中（跳过）"
fi
echo ""

echo -e "${BLUE}[检查 9/10]${NC} 文件完整性"
echo "----------------------------------------"
# 检查 SKILL.md 格式 (应该包含标题)
grep -q "# Clash Proxy Skill" /app/skills/clash-skill/SKILL.md 2>/dev/null
check_true "SKILL.md 格式正确"

# 检查 handler.js 格式 (应该包含 export default)
grep -q "export default" /app/skills/clash-skill/hooks/clash-startup/handler.js 2>/dev/null
check_true "handler.js 包含导出语句"

# 检查 clash.sh 格式 (应该包含 start)
grep -q "start)" /app/skills/clash-skill/scripts/clash.sh 2>/dev/null
check_true "clash.sh 包含 start 命令"
echo ""

echo -e "${BLUE}[检查 10/10]${NC} Clash 二进制文件（如果已安装）"
echo "----------------------------------------"
if command -v clash &>/dev/null; then
    check_true "clash 命令可用"

    # 获取版本
    CLASH_VERSION=$(clash -v 2>/dev/null || echo "未知")
    echo -e "  版本: ${CLASH_VERSION}"
elif [ -f "/home/node/bin/clash" ]; then
    check_true "clash 二进制文件存在"
else
    echo -e "${YELLOW}⊜${NC} Clash 未安装（需要先运行 install.sh）"
fi
echo ""

echo "=========================================="
echo -e "验证完成"
echo "=========================================="
echo -e "${GREEN}成功:${NC} $SUCCESS_COUNT"
echo -e "${RED}失败:${NC} $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ 所有检查通过！${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ 有 $FAIL_COUNT 个检查失败${NC}"
    exit 1
fi
