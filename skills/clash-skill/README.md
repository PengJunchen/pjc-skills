# Clash Proxy Skill for OpenClaw

[![Status](https://img.shields.io/badge/status-production-green.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()
[![Last Update](https://img.shields.io/badge/last_update-2026--02--28-blue.svg)]()

OpenClaw 的 Clash 代理管理技能，支持自动启动、状态监控和代理切换。

---

## 🚀 快速开始

### 3 分钟配置自动启动

```bash
# 1. 确保 clash-skill 在 workspace 目录
ls ~/.openclaw/workspace/clash-skill/scripts/clash.sh

# 如果不存在：
cp -r ~/.openclaw/workspace/pjc-skills/skills/clash-skill \
      ~/.openclaw/workspace/clash-skill

# 2. 创建 BOOT.md
cp ~/.openclaw/workspace/clash-skill/templates/BOOT.md \
   ~/.openclaw/workspace/BOOT.md

# 3. 重启 Gateway
openclaw gateway restart

# 完成！Clash 将自动启动
```

详细说明：[快速开始指南](QUICKSTART.md) | [完整解决方案](CLASH_AUTO_STARTUP_COMPLETE.md)

---

## ⭐ 主要功能

- ✅ **自动启动** - Gateway 重启后自动启动 Clash
- ✅ **状态监控** - 实时监控 Clash 进程状态
- ✅ **代理切换** - 快速切换代理环境变量
- ✅ **多种方案** - BOOT.md、Gateway Hook、Cron 中选择
- ✅ **工具丰富** - 状态检查、验证、诊断工具

---

## 📦 安装

### 方法 1：使用安装脚本（推荐）

```bash
cd ~/.openclaw/workspace/pjc-skills
bash install-to-openclaw.sh
```

### 方法 2：手动安装

详见：[安装文档](docs/SETUP.md)

---

## 📚 文档索引

### 快速入门
- **[快速开始指南](QUICKSTART.md)** - 3 分钟配置自动启动 ⚡
- **[完整解决方案](CLASH_AUTO_STARTUP_COMPLETE.md)** - 详细的自动启动方案 ⭐
- **[技能说明](SKILL.md)** - 完整的技能功能说明

### 进阶内容
- **[安装指南](docs/SETUP.md)** - 详细安装步骤
- **[使用指南](docs/USAGE.md)** - 日常使用技巧
- **[经验总结](EXPERIENCE_SUMMARY.md)** - 最佳实践和经验教训

### 参考文档
- **[故障排查](docs/TROUBLESHOOTING.md)** - 常见问题解决
- **[历史记录](CLASH_AUTO_STARTUP_HISTORY.md)** - 问题解决过程
- **[完成总结](COMPLETION_SUMMARY.md)** - 项目完成报告

---

## 🔧 工具脚本

### 状态检查工具

```bash
bash tools/check-status.sh
```

检查 Gateway、Clash、Hook 等各方面的状态。

### 验证脚本

```bash
bash verify.sh
```

验证 skill 的完整性和功能。

### Cron 启动脚本

```bash
bash scripts/clash-cron-startup.sh
```

用于 Cron @reboot 任务的启动脚本。

---

## 🎯 三种自动启动方案

| 方案 | 复杂度 | 可靠性 | 推荐 | 适用场景 |
|------|--------|--------|------|----------|
| **BOOT.md** | ⭐ | ⭐⭐⭐⭐⭐ | ✅ | 所有人（首选） |
| **Gateway Hook** | ⭐⭐⭐⭐ | ⭐⭐⭐ | 高级用户 | 需要详细日志 |
| **Cron** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | WSL2 | 容器/WSL2 环境 |

详细对比：[完整解决方案](CLASH_AUTO_STARTUP_COMPLETE.md)

---

## 🛠️ 使用示例

### 基本操作

```bash
# 启动 Clash
bash scripts/clash.sh start

# 停止 Clash
bash scripts/clash.sh stop

# 重启 Clash
bash scripts/clash.sh restart

# 查看状态
bash scripts/clash.sh status

# 更新订阅
bash scripts/clash.sh update
```

### 代理切换

```bash
# 启用代理
source scripts/proxy.sh

# 禁用代理
source scripts/proxy.sh off

# 查看状态
source scripts/proxy.sh status

# 测试连接
test_proxy
```

---

## 📋 项目结构

```
clash-skill/
├── SKILL.md                      ⭐ 主要技能文档
├── QUICKSTART.md                 🚀 快速开始
├── CLASH_AUTO_STARTUP_COMPLETE.md ⭐ 完整解决方案
│
├── scripts/                      ⚙️ 脚本目录
│   ├── clash.sh                  控制脚本
│   ├── clash-monitor.sh          监控脚本
│   ├── clash-cron-startup.sh     Cron 启动脚本
│   └── proxy.sh                  代理切换
│
├── tools/                        🔧 工具目录
│   └── check-status.sh           状态检查工具
│
├── hooks/                        🪝 OpenClaw Hooks
│   └── clash-startup/            Gateway Startup Hook
│
├── templates/                    📋 模板文件
│   └── BOOT.md                  BOOT.md 模板
│
└── docs/                         📚 详细文档
    ├── SETUP.md                 安装文档
    ├── USAGE.md                 使用指南
    └── TROUBLESHOOTING.md       故障排查
```

---

## 🔍 故障排查

### Clash 没有自动启动

```bash
# 1. 运行状态检查
bash tools/check-status.sh

# 2. 检查日志
cat /tmp/clash-startup.log
cat /tmp/boot.log

# 3. 手动测试
bash scripts/clash.sh start
bash scripts/clash.sh status
```

详细故障排查：[故障排查文档](docs/TROUBLESHOOTING.md)

---

## 💡 关键经验

从问题解决中学到的关键经验：

1. **进程检测** - 使用 `pgrep -x` 而不是 `pgrep -f`
2. **stdio 重定向** - 始终使用 `{ stdio: "pipe" }`
3. **启动验证** - 不只执行命令，还要验证结果
4. **路径配置** - 使用相对路径或多路径检测
5. **多层策略** - 不要只依赖单一方法

详细经验总结：[经验总结](EXPERIENCE_SUMMARY.md)

---

## 📊 更新记录

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-02-28 | V3 | ✅ 完整自动启动解决方案，新增工具和文档 |
| 2026-02-28 | V2 | ✅ 修复 Hook 进程检测 bug，添加详细日志 |
| 2026-02-27 | V1 | ✅ 初始版本，基础功能 |

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License

---

## 🙏 致谢

- Clash Meta (Mihomo) - 强大的代理工具
- OpenClaw - 优秀的 AI 工具框架

---

**最后更新**: 2026-02-28 08:35 UTC
**项目状态**: ✅ 完成并部署
**验证状态**: ✅ 所有关键测试通过
