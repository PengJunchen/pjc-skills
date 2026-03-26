# pjc-skills 一键安装和初始化脚本 (PowerShell 版本)
# 适用于 Claude Code 和 OpenClaw

param(
    [string]$SubscriptionUrl = ""
)

# 颜色输出函数
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

# 获取脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  pjc-skills 一键安装和初始化" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检测环境
Write-Step "检测运行环境..."

# 检测是否在 OpenClaw 环境中
$OpenClawHome = $env:OPENCLAW_HOME
$OpenClawWorkspace = $env:OPENCLAW_WORKSPACE
$OpenClawDir = Join-Path $env:USERPROFILE ".openclaw"

if ($OpenClawHome -or (Test-Path $OpenClawDir)) {
    $Environment = "openclaw"
    Write-Info "检测到 OpenClaw 环境"
    
    # 确定 OpenClaw workspace 路径
    if ($OpenClawWorkspace) {
        $WorkspaceDir = $OpenClawWorkspace
    } else {
        $OpenClawConfig = Join-Path $OpenClawDir "openclaw.json"
        if (Test-Path $OpenClawConfig) {
            $Config = Get-Content $OpenClawConfig | ConvertFrom-Json
            $WorkspaceDir = $Config.workspace
        } else {
            $WorkspaceDir = Join-Path $OpenClawDir "workspace"
        }
    }
    
    Write-Info "Workspace 路径: $WorkspaceDir"
} else {
    $Environment = "claude-code"
    Write-Info "检测到 Claude Code 环境"
    $WorkspaceDir = $ProjectDir
}

# 检查项目结构
Write-Step "检查项目结构..."

$SkillsDir = Join-Path $ProjectDir "skills"
$MarketplaceJson = Join-Path $ProjectDir ".claude-plugin\marketplace.json"

if (-not (Test-Path $SkillsDir)) {
    Write-Error "skills 目录不存在: $SkillsDir"
    exit 1
}

if (-not (Test-Path $MarketplaceJson)) {
    Write-Error "marketplace.json 不存在: $MarketplaceJson"
    exit 1
}

Write-Info "项目结构检查通过"

# 初始化 clash-skill（如果需要）
Write-Step "初始化 clash-skill..."

$ClashSkillDir = Join-Path $SkillsDir "clash-skill"

if (Test-Path $ClashSkillDir) {
    Write-Info "clash-skill 已存在"
    
    # 检查是否需要安装 Clash
    $BinDir = Join-Path $env:USERPROFILE "bin"
    $ClashBin = Join-Path $BinDir "clash.exe"
    
    if (-not (Test-Path $ClashBin)) {
        Write-Warn "Clash 未安装（Windows 版本需要手动配置）"
        Write-Host ""
        Write-Host "注意：clash-skill 主要针对 Linux 系统（Ubuntu/Debian/WSL2）" -ForegroundColor Yellow
        Write-Host "在 Windows 上，建议使用 WSL2 运行 clash-skill" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Info "Clash 已安装"
    }
} else {
    Write-Warn "clash-skill 目录不存在"
}

# 初始化 gemini-cli
Write-Step "初始化 gemini-cli..."

$GeminiSkillDir = Join-Path $SkillsDir "gemini-cli"

if (Test-Path $GeminiSkillDir) {
    Write-Info "gemini-cli 已存在"
    
    # 检查 websockets 依赖
    try {
        python -c "import websockets" 2>$null
        Write-Info "websockets 已安装"
    } catch {
        Write-Warn "websockets 未安装"
        Write-Host ""
        Write-Host "请运行以下命令安装依赖:" -ForegroundColor Yellow
        Write-Host "  pip install websockets" -ForegroundColor Gray
        Write-Host ""
    }
} else {
    Write-Warn "gemini-cli 目录不存在"
}

# 配置 OpenClaw 集成
if ($Environment -eq "openclaw") {
    Write-Step "配置 OpenClaw 集成..."
    
    # 检查 BOOT.md 文件
    $BootFile = Join-Path $WorkspaceDir "BOOT.md"
    
    if (Test-Path $BootFile) {
        Write-Info "BOOT.md 已存在"
        
        # 检查是否已配置 clash-skill 启动
        $BootContent = Get-Content $BootFile -Raw
        if ($BootContent -match "clash-skill") {
            Write-Info "clash-skill 启动配置已存在"
        } else {
            Write-Warn "建议在 BOOT.md 中添加 clash-skill 启动配置"
            Write-Host ""
            Write-Host "在 $BootFile 中添加以下内容:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "# 启动 Clash 代理" -ForegroundColor Gray
            Write-Host "if [ -f `"clash-skill/scripts/clash.sh`" ]; then" -ForegroundColor Gray
            Write-Host "    bash clash-skill/scripts/clash.sh start" -ForegroundColor Gray
            Write-Host "fi" -ForegroundColor Gray
            Write-Host ""
        }
    } else {
        Write-Info "BOOT.md 不存在，创建模板..."
        
        $BootContent = @"
# pjc-skills OpenClaw 启动脚本

# 启动 Clash 代理（如果已安装）
if [ -f "clash-skill/scripts/clash.sh" ]; then
    echo "[$(date)] [BOOT] Starting Clash proxy..."
    bash clash-skill/scripts/clash.sh start
fi
"@
        
        $BootContent | Out-File -FilePath $BootFile -Encoding UTF8
        Write-Info "已创建 BOOT.md: $BootFile"
    }
    
    # 检查 cron 配置
    $CronFile = Join-Path $OpenClawDir "cron\jobs.json"
    
    if (Test-Path $CronFile) {
        Write-Info "cron 配置已存在"
        
        # 检查是否已配置 clash-monitor
        $CronContent = Get-Content $CronFile -Raw
        if ($CronContent -match "clash-monitor") {
            Write-Info "clash-monitor cron 任务已配置"
        } else {
            Write-Warn "建议在 cron 配置中添加 clash-monitor"
            Write-Host ""
            Write-Host "在 $CronFile 中添加以下任务:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "{" -ForegroundColor Gray
            Write-Host '  "name": "clash-monitor",' -ForegroundColor Gray
            Write-Host '  "schedule": "* * * * *",' -ForegroundColor Gray
            Write-Host '  "command": "bash \"$HOME/.openclaw/workspace/clash-skill/scripts/clash-monitor.sh\"",' -ForegroundColor Gray
            Write-Host '  "description": "Monitor and restart Clash if not running",' -ForegroundColor Gray
            Write-Host '  "enabled": true' -ForegroundColor Gray
            Write-Host "}" -ForegroundColor Gray
            Write-Host ""
        }
    } else {
        Write-Info "cron 配置目录不存在，跳过"
    }
}

# 配置 Claude Code 插件
if ($Environment -eq "claude-code") {
    Write-Step "配置 Claude Code 插件..."
    
    Write-Info "使用以下命令注册插件市场:"
    Write-Host ""
    Write-Host "  /plugin marketplace add pjc/pjc-skills" -ForegroundColor White
    Write-Host ""
    Write-Host "或直接安装技能:" -ForegroundColor White
    Write-Host "  /plugin install proxy-skills@pjc-skills" -ForegroundColor White
    Write-Host ""
}

# 显示安装摘要
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Info "安装和初始化完成！"
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 环境信息:" -ForegroundColor White
Write-Host "  环境: $Environment" -ForegroundColor Gray
Write-Host "  项目目录: $ProjectDir" -ForegroundColor Gray
Write-Host "  Workspace: $WorkspaceDir" -ForegroundColor Gray
Write-Host ""
Write-Host "📦 已安装技能:" -ForegroundColor White
Write-Host "  - clash-skill (代理管理)" -ForegroundColor Gray
Write-Host "  - gemini-cli (Gemini AI 自动化)" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 下一步操作:" -ForegroundColor White
Write-Host ""

if ($Environment -eq "openclaw") {
    Write-Host "  1. 在 WSL2 中安装 Clash:" -ForegroundColor White
    Write-Host "     wsl bash $ClashSkillDir/scripts/install.sh <订阅链接>" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. 启动 Clash:" -ForegroundColor White
    Write-Host "     wsl bash $ClashSkillDir/scripts/clash.sh start" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. 启用代理:" -ForegroundColor White
    Write-Host "     wsl source $ClashSkillDir/scripts/proxy.sh" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  4. 测试连接:" -ForegroundColor White
    Write-Host "     wsl curl -I https://www.google.com" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  5. 查看 BOOT.md 配置:" -ForegroundColor White
Write-Host "     cat $BootFile" -ForegroundColor Gray
Write-Host ""
Write-Host "  6. 使用 gemini-cli (Gemini AI 自动化):" -ForegroundColor White
Write-Host "     pip install websockets" -ForegroundColor Gray
Write-Host "     browser(action='start', profile='chrome')" -ForegroundColor Gray
Write-Host "     browser(action='open', url='https://gemini.google.com/app')" -ForegroundColor Gray
Write-Host "     py $GeminiSkillDir\scripts\gemini_image.py --prompt '一只猫' --style 油画" -ForegroundColor Gray
Write-Host ""
} else {
    Write-Host "  1. 注册插件市场:" -ForegroundColor White
    Write-Host "     /plugin marketplace add pjc/pjc-skills" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. 安装技能:" -ForegroundColor White
    Write-Host "     /plugin install proxy-skills@pjc-skills" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. 查看技能文档:" -ForegroundColor White
    Write-Host "     cat $ClashSkillDir/SKILL.md" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "📚 文档资源:" -ForegroundColor White
$ReadmeFile = Join-Path $ProjectDir "README.md"
Write-Host "  - 项目 README: $ReadmeFile" -ForegroundColor Gray
$ClashReadme = Join-Path $ClashSkillDir "README.md"
Write-Host "  - clash-skill 文档: $ClashReadme" -ForegroundColor Gray
$SetupDoc = Join-Path $ClashSkillDir "docs\SETUP.md"
Write-Host "  - 安装指南: $SetupDoc" -ForegroundColor Gray
$UsageDoc = Join-Path $ClashSkillDir "docs\USAGE.md"
Write-Host "  - 使用指南: $UsageDoc" -ForegroundColor Gray
$TroubleshootDoc = Join-Path $ClashSkillDir "docs\TROUBLESHOOTING.md"
Write-Host "  - 故障排查: $TroubleshootDoc" -ForegroundColor Gray
$GeminiSkillDoc = Join-Path $GeminiSkillDir "SKILL.md"
Write-Host "  - gemini-cli 文档: $GeminiSkillDoc" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ 安装完成！" -ForegroundColor Green
Write-Host ""
