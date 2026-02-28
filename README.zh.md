# pjc-skills

[English](./README.md) | 中文

PJC 分享的技能集合，用于提高 OpenClaw 的日常工作效率。

## 前置要求

- OpenClaw 已安装并配置
- Linux 系统（Ubuntu/Debian/WSL2）用于代理技能
- Bash shell 环境
- 网络访问权限（用于下载 Clash）

## 安装

### 快速安装（推荐用于 OpenClaw）

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

### 手动安装

1. **复制 pjc-skills 目录**到你的 OpenClaw 工作目录：
   ```bash
   cp -r pjc-skills ~/.openclaw/workspace/
   ```

2. **运行安装脚本**：
   ```bash
   cd ~/.openclaw/workspace/pjc-skills
   bash install.sh
   ```

### 可用插件

| 插件 | 描述 | 技能 |
|------|------|------|
| **proxy-skills** | 代理和网络管理 | [clash-skill](#clash-skill) |

## 更新技能

要更新技能到最新版本：

1. **下载最新版本**的 pjc-skills
2. **替换现有的** pjc-skills 目录到你的 OpenClaw 工作目录
3. **再次运行安装脚本**以确保所有依赖项都已更新：
   ```bash
   cd ~/.openclaw/workspace/pjc-skills
   bash install.sh
   ```

## 可用技能

### 代理技能

#### clash-skill

完整的 Clash 代理管理技能，用于自动化安装、配置和管理。

**特性：**
- ✅ 自动安装 Clash Meta (Mihomo)
- ✅ 订阅链接集成，自动导入节点
- ✅ 进程管理（启动/停止/重启/状态）
- ✅ 通过 cron 任务自动监控
- ✅ OpenClaw 集成，支持自动启动
- ✅ 快速切换代理环境变量
- ✅ 通过 REST API 管理节点

**平台支持：** 仅支持 Linux（Ubuntu/Debian/WSL2）

**快速开始：**

```bash
# 使用订阅链接安装 Clash
cd ~/.openclaw/workspace/pjc-skills/skills/clash-skill
bash scripts/install.sh <订阅链接>

# 启动 Clash
bash scripts/clash.sh start

# 启用代理
source scripts/proxy.sh

# 测试连接
curl -I https://www.google.com
```

**文档：**
- [SKILL.md](skills/clash-skill/SKILL.md) - 完整技能文档
- [README.md](skills/clash-skill/README.md) - 详细使用指南
- [SETUP.md](skills/clash-skill/docs/SETUP.md) - 安装指南
- [USAGE.md](skills/clash-skill/docs/USAGE.md) - 使用技巧
- [TROUBLESHOOTING.md](skills/clash-skill/docs/TROUBLESHOOTING.md) - 常见问题

## 项目结构

```
pjc-skills/
├── skills/
│   └── clash-skill/           # Clash 代理管理技能
│       ├── SKILL.md          # 技能文档
│       ├── README.md         # 技能说明
│       ├── scripts/          # Shell 脚本
│       │   ├── install.sh     # 安装脚本
│       │   ├── clash.sh      # 控制脚本
│       │   ├── clash-monitor.sh  # 监控脚本
│       │   └── proxy.sh      # 代理环境脚本
│       ├── docs/             # 文档
│       ├── config/           # 配置模板
│       └── templates/        # 集成模板
├── README.md                 # 英文说明
├── README.zh.md              # 中文说明（本文件）
├── install.sh                # Bash 安装脚本
├── install.ps1               # PowerShell 安装脚本
├── .gitignore                # Git 忽略文件
└── LICENSE                   # 许可证文件
```

## 开发

### 添加新技能

1. 创建技能目录：`skills/<skill-name>/`
2. 创建 `SKILL.md` 文件，包含适当的文档
3. 在 `scripts/` 或适当的子目录中添加实现
4. 更新文档

### 技能命名约定

所有技能应使用描述性名称，不带前缀，以保持清晰并避免冲突。

## 贡献

欢迎贡献！请随时提交 Pull Request。

## 许可证

详见 [LICENSE](LICENSE) 文件。

## 支持

如有问题和疑问：
- 查看每个技能目录中的文档
- 在 GitHub 上提交 issue

---

**创建者**: PJC
**最后更新**: 2026-02-27
