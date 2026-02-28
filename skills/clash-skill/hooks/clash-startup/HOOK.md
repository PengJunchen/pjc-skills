---
name: clash-startup
description: "Automatically start Clash proxy on gateway startup"
metadata: { "openclaw": { "emoji": "🌐", "events": ["gateway:startup"], "requires": { "bins": ["bash"] } } }
---

# Clash Startup Hook

自动在 OpenClaw Gateway 启动时启动 Clash 代理服务。

## 触发时机

Gateway 启动时（`gateway:startup` 事件）。

## 行为

本 hook 会自动执行以下操作：

1. 检查 Clash 是否已在运行
2. 如果未运行，启动 Clash 代理服务
3. 记录启动日志到 `/tmp/clash-startup.log`

## 无需手动介入

此 hook 完全自动化，与 BOOT.md 独立工作。
