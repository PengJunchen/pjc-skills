# pjc-skills

English | [中文](./README.zh.md)

Skills shared by PJC for improving daily work efficiency with OpenClaw.

## Prerequisites

- OpenClaw installed and configured
- Linux system (Ubuntu/Debian/WSL2) for proxy skills
- Bash shell environment
- Network access for downloading Clash

## Installation

### Quick Install (Recommended for OpenClaw)

```bash
# 进入 OpenClaw 工作目录
cd ~/.openclaw/workspace

# 克隆或复制 pjc-skills 目录
# 方法 1: 克隆仓库
# git clone https://github.com/PJC/pjc-skills.git

# 方法 2: 直接复制目录
# cp -r /path/to/pjc-skills .

# 运行一键安装脚本
bash pjc-skills/install.sh
```

### Manual Install

1. **Copy pjc-skills directory** to your OpenClaw workspace:
   ```bash
   cp -r pjc-skills ~/.openclaw/workspace/
   ```

2. **Run the installation script**:
   ```bash
   cd ~/.openclaw/workspace/pjc-skills
   bash install.sh
   ```

### Available Plugins

| Plugin | Description | Skills |
|--------|-------------|--------|
| **proxy-skills** | Proxy and network management | [clash-skill](#clash-skill) |

## Update Skills

To update skills to the latest version:

1. **Download the latest version** of pjc-skills
2. **Replace the existing** pjc-skills directory in your OpenClaw workspace
3. **Run the installation script** again to ensure all dependencies are updated:
   ```bash
   cd ~/.openclaw/workspace/pjc-skills
   bash install.sh
   ```

## Available Skills

### Proxy Skills

#### clash-skill

A complete Clash proxy management skill for automated installation, configuration, and management.

**Features:**
- ✅ Automated Clash Meta (Mihomo) installation
- ✅ Subscription link integration for automatic node import
- ✅ Process management (start/stop/restart/status)
- ✅ Automatic monitoring via cron jobs
- ✅ OpenClaw integration for auto-startup
- ✅ Quick proxy environment variable switching
- ✅ Node management via REST API

**Platform Support:** Linux only (Ubuntu/Debian/WSL2)

**Quick Start:**

```bash
# Install Clash with subscription link
cd ~/.openclaw/workspace/pjc-skills/skills/clash-skill
bash scripts/install.sh <subscription-url>

# Start Clash
bash scripts/clash.sh start

# Enable proxy
source scripts/proxy.sh

# Test connection
curl -I https://www.google.com
```

**Documentation:**
- [SKILL.md](skills/clash-skill/SKILL.md) - Complete skill documentation
- [README.md](skills/clash-skill/README.md) - Detailed usage guide
- [SETUP.md](skills/clash-skill/docs/SETUP.md) - Installation guide
- [USAGE.md](skills/clash-sill/docs/USAGE.md) - Usage tips
- [TROUBLESHOOTING.md](skills/clash-skill/docs/TROUBLESHOOTING.md) - Common issues

## Project Structure

```
pjc-skills/
├── skills/
│   └── clash-skill/           # Clash proxy management skill
│       ├── SKILL.md          # Skill documentation
│       ├── README.md         # Skill README
│       ├── scripts/          # Shell scripts
│       │   ├── install.sh     # Installation script
│       │   ├── clash.sh      # Control script
│       │   ├── clash-monitor.sh  # Monitoring script
│       │   └── proxy.sh      # Proxy environment script
│       ├── docs/             # Documentation
│       ├── config/           # Configuration templates
│       └── templates/        # Integration templates
├── README.md                 # This file
├── README.zh.md              # Chinese version
├── install.sh                # Bash installation script
├── install.ps1               # PowerShell installation script
├── .gitignore                # Git ignore file
└── LICENSE                   # License file
```

## Development

### Adding New Skills

1. Create skill directory: `skills/<skill-name>/`
2. Create `SKILL.md` with proper documentation
3. Add implementation in `scripts/` or appropriate subdirectories
4. Update documentation

### Skill Naming Convention

All skills should use descriptive names without prefixes to maintain clarity and avoid conflicts.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
- Check the documentation in each skill's directory
- Open an issue on GitHub

---

**Created by**: PJC
**Last updated**: 2026-02-27
