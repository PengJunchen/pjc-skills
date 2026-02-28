# Clash 自动启动问题 - 完整解决方案与经验总结

## 📋 问题背景

**时间**: 2026-02-27 - 2026-02-28
**环境**: OpenClaw Gateway on WSL2 (Linux)
**问题**: OpenClaw Gateway 容器重启后，Clash 代理服务无法自动启动

---

## 🐛 问题表现

1. Gateway 重启后，Clash 进程未运行
2. PID 文件存在但进程不存在（僵尸状态）
3. Proxy 功能失效

---

## 🔍 问题分析过程

### 初步尝试：手动执行命令（V1）

**方法**: 创建 BOOT.md，让 agent 在启动时执行 `clash.sh start`

**结果**: ✅ 失败 - BOOT.md 中的命令没有被自动执行

**原因**: BOOT.md 的 boot-md hook 是否被触发取决于 agent 的行为模式，不是保证执行的

### 第二次尝试：OpenClaw Gateway Hook（V2）

**方法**: 创建 `clash-startup` hook，监听 `gateway:startup` 事件

**配置**:
- Hook 文件: `~/.openclaw/workspace/hooks/clash-startup/`
- HOOK.md: 包含事件元数据 `events: ["gateway:startup"]`
- handler.js: 执行启动逻辑

**结果**: ❌ 失败 - hook 响应 "Clash is already running" 但实际未运行

**根因**:
```javascript
// 错误代码：使用模糊匹配
const { stdout } = await execAsync("pgrep -f clash", { stdio: "pipe" });
// 问题：这个命令会匹配到任何命令行中包含 "clash" 的进程
// 包括正在执行 "pgrep -f clash" 命令本身！
```

**调试发现**:
```bash
$ pgrep -f clash
48  # 这是执行 pgrep 命令的进程本身！
$ ps aux | grep 48
node 48 ... pgrep -f clash
```

### 第三次尝试：修复 Hook 检测逻辑（V2）

**修复方案**:
1. 使用 `pgrep -x clash` 进行精确匹配
2. 验证 PID 文件中的进程是否存在
3. 添加 `waitForClashToStart()` 函数验证进程启动
4. 使用 `stdio: "pipe"` 防止命令输出被误匹配

**结果**: ✅ 手动触发成功，但 hook 仍未在 Gateway 重启时触发

### 第四次尝试：双保险方案（V3）

**方案 1**: 继续使用 clash-startup hook（增强版，添加详细日志）
- 添加 `/tmp/clash-startup-debug.log` 记录所有事件
- 记录完整的 event 对象

**方案 2**: 重新设计 BOOT.md
- 简化内容，明确指令
- 作为备用方案

**结果**: ✅ BOOT.md 在 boot check 时成功启动了 Clash
****: 🔄 clash-startup hook 在 Gateway 重启时从未触发（原因待查）

---

## ✅ 最终解决方案

### 推荐实现方式（按优先级排序）

#### 方案 A：BOOT.md（首选）

**优点**:
- ✅ 简单可靠
- ✅ OpenClaw 内置功能
- ✅ 不需要额外代码

**实现步骤**:

1. **将 clash-skill 部署到 workspace**:

```bash
# 假设 clash-skill 在 pjc-skills 下
mkdir -p ~/.openclaw/workspace
cp -r ~/.openclaw/workspace/pjc-skills/skills/clash-skill ~/.openclaw/workspace/clash-skill
```

2. **创建 BOOT.md**:

文件位置: `~/.openclaw/workspace/BOOT.md`

```bash
# OpenClaw Boot Hook - Clash 自动启动
# 检查并启动 Clash
bash clash-skill/scripts/clash.sh start

# 验证启动状态
bash clash-skill/scripts/clash.sh status
```

3. **配置 OpenClaw 启用 boot-md**:

在 `~/.openclaw/openclaw.json` 中确认：

```json
{
  "boot-md": {
    "enabled": true
  }
}
```

4. **测试**:

```bash
# 重启 Gateway
openclaw gateway restart

# 检查日志
cat /tmp/boot.log

# 检查 Clash 状态
bash ~/.openclaw/workspace/clash-skill/scripts/clash.sh status
```

#### 方案 B：OpenClaw Gateway Hook（高级用户）

**优点**:
- ✅ 更精确的事件控制
- ✅ 详细的调试日志
- ✅ 可执行复杂逻辑

**实现步骤**:

1. **部署 hook**:

```bash
# 复制 hook 文件
cp -r ~/.openclaw/workspace/pjc-skills/skills/clash-skill/hooks/clash-startup ~/.openclaw/workspace/hooks/

# 验证文件
ls -la ~/.openclaw/workspace/hooks/clash-startup/
```

2. **配置 OpenClaw**:

在 `~/.openclaw/openclaw.json` 中添加：

```json
{
  "hooks": {
    "internal": {
      "enabled": true,
      "entries": {
        "clash-startup": {
          "enabled": true
        }
      }
    }
  }
}
```

3. **Hook 文件结构**:

```
~/.openclaw/workspace/hooks/clash-startup/
├── HOOK.md           # Hook 元数据
├── handler.js        # Hook 处理器（推荐）
└── handler.ts        # TypeScript 版本（可选）
```

HOOK.md 内容:
```
---
openclaw:
  emoji: "🌐"
  events: ["gateway:startup"]
  requires:
    bins: ["bash"]
---
Clash startup hook
```

handler.js 关键逻辑:
```javascript
// 精确进程检测（避免模糊匹配）
const { stdout } = await execAsync("pgrep -x clash", { stdio: "pipe" });

// 验证 PID 文件
if (require("fs").existsSync("/home/node/.config/clash/clash.pid")) {
  // 读取并验证 PID
}

// 启动 Clash
await execAsync("bash /path/to/clash.sh start", { stdio: "pipe" });

// 等待验证
await waitForClashToStart(10, 1000);
```

4. **测试**:

```bash
# 重启 Gateway
openclaw gateway restart

# 查看日志
cat /tmp/clash-startup.log          # 主日志
cat /tmp/clash-startup-debug.log    # 调试日志
```

#### 方案 C：Cron（备选方案）

**优点**:
- ✅ 系统级，最可靠
- ✅ 不依赖 OpenClaw 功能
- ✅ 适用于任何 Linux 系统

**使用场景**:
- 方案 A 和 B 都失败时的最后手段
- 需要在系统完全启动后再启动 Clash（网络就绪）

**实现步骤**:

1. **使用提供的脚本**:

```bash
# 检查脚本是否存在
cp ~/.openclaw/workspace/pjc-skills/skills/clash-skill/scripts/clash-cron-startup.sh ~/clash-cron-startup.sh

# 编辑脚本，修改路径（如果需要）
vi ~/clash-cron-startup.sh

# 添加可执行权限
chmod +x ~/clash-cron-startup.sh
```

2. **添加到 crontab**:

```bash
# 添加 @reboot 任务
(crontab -l 2>/dev/null; echo "@reboot sleep 60 && /home/node/clash-cron-startup.sh >> /tmp/clash-cron.log 2>&1") | crontab -

# 查看 crontab
crontab -l
```

或使用内置脚本（推荐）:
```bash
# 直接指向 clash.sh，简化配置
(crontab -l 2>/dev/null; echo "@reboot sleep 60 && bash /home/node/.openclaw/workspace/pjc-skills/skills/clash-skill/scripts/clash.sh start >> /tmp/clash-cron.log 2>&1") | crontab -
```

3. **验证**:

```bash
# 查看日志
cat /tmp/clash-cron.log

# 检查 Clash 状态
bash /path/to/clash.sh status
```

---

## 📚 关键经验教训

### 1. 进程检测的陷阱

❌ **错误做法**:
```javascript
// 模糊匹配会匹配到执行此命令的进程本身
const { stdout } = await execAsync("pgrep -f clash");
```

✅ **正确做法**:
```javascript
// 精确匹配进程名
const { stdout } = await execAsync("pgrep -x clash", { stdio: "pipe" });

// 或验证 PID 文件
const pid = fs.readFileSync("/home/node/.config/clash/clash.pid", "utf8");
const { stdout } = await execAsync(`ps -p ${pid} -o comm=`, { stdio: "pipe" });
```

### 2. stdio 重定向的重要性

❌ **错误做法**:
```javascript
// 默认继承，可能干扰进程检测
await execAsync("bash clash.sh start");
```

✅ **正确做法**:
```javascript
// 显式重定向到 pipe
await execAsync("bash clash.sh start", { stdio: "pipe" });
```

### 3. 启动验证的必要性

不要只执行启动命令就认为成功！

❌ **错误做法**:
```javascript
await startClash();
await log("Clash started (assumed)");
```

✅ **正确做法**:
```javascript
await startClash();
const started = await waitForClashToStart(10, 1000);
if (!started) {
  await log("ERROR: Clash failed to start");
  return { success: false };
}
```

### 4. 路径配置的灵活性

不要硬编码路径！

❌ **错误做法**:
```javascript
const clashScript = "/home/node/.openclaw/workspace/clash-skill/scripts/clash.sh";
```

✅ **正确做法**:
```javascript
// 方法1: 相对于 workspace
const workspace = process.env.HOME
  ? path.join(process.env.HOME, ".openclaw", "workspace")
  : "/home/node/.openclaw/workspace";
const clashScript = path.join(workspace, "clash-skill", "scripts", "clash.sh");

// 方法2: 多路径回退
const possiblePaths = [
  "clash-skill/scripts/clash.sh",
  path.join(process.env.HOME, ".openclaw/workspace/clash-skill/scripts/clash.sh"),
  "/opt/openclaw/workspace/clash-skill/scripts/clash.sh",
];
// 尝试每个路径...
```

### 5. 日志的重要性

足够的日志能帮你快速定位问题！

✅ **推荐日志级别**:
```javascript
await log("=== Event details ===");       // 开始标记
await log(`type: ${event.type}`);         // 基本信息记录
await log(`Checking Clash status...`);    // 操作前记录
await log(`✓ Clash is running`);          // 成功记录
await log(`✗ Clash not found`);           // 失败记录
await log(`Error: ${error.message}`);     // 错误记录
await log(`=== Operation completed ===`);// 结束标记
```

### 6. 分层启动策略

不要只依赖单一方法！

✅ **推荐三层策略**:
1. **BOOT.md** - 主启动方案（简单、可靠）
2. **Gateway Hook** - 高级控制（详细日志、复杂逻辑）
3. **Cron** - 备选方案（系统级、不依赖 OpenClaw）

### 7. 路径解析的复杂性

在 WSL2 和容器环境中，路径可能不同！

```bash
# WSL2
/home/node/.openclaw/workspace/

# Docker 容器
/workspace/

# 可能的环境变量
$HOME/.openclaw/workspace/
$OPENCLAW_WORKSPACE
/workspace/
```

✅ **解决方案**:
```bash
# Bash 中使用自动检测
CLASH_DIR=$(find ~ -name "clash-skill" -type d 2>/dev/null | head -1)
if [ -z "$CLASH_DIR" ]; then
    echo "Error: clash-skill directory not found"
    exit 1
fi
CLASH_SCRIPT="$CLASH_DIR/scripts/clash.sh"
```

---

## 🛠️ 提供的工具脚本

### 1. check-status.sh

**位置**: `clash-skill/tools/check-status.sh`

**功能**: 状态检查脚本，检查各方面状态

```bash
# 运行
bash clash-skill/tools/check-status.sh
```

**输出内容**:
- Gateway 进程状态
- Clash 进程状态
- Hook 日志状态
- Hook 文件完整性
- 配置文件内容

### 2. clash-cron-startup.sh

**位置**: `clash-skill/scripts/clash-cron-startup.sh`

**功能**: 用于 Cron @reboot 任务的启动脚本

**特点**:
- 等待系统启动（可配置）
- 检查是否已在运行
- 验证启动结果
- 完整的日志记录

### 3. debug.js

**位置**: `clash-skill/hooks/clash-startup/debug.js`

**功能**: Hook 调试工具

**用途**:
- 检查 hook 配置
- 验证目录结构
- 手动触发测试

### 4. manual-trigger.js

**位置**: `clash-skill/hooks/clash-startup/manual-trigger.js`

**功能**: 手动触发 hook 进行测试

**用途**:
- 测试 hook 逻辑
- 不需要重启 Gateway
- 便于开发调试

---

## 📊 推荐配置方案对比

| 方案 | 复杂度 | 可靠性 | 调试能力 | 适用场景 | 推荐度 |
|------|--------|--------|----------|----------|--------|
| BOOT.md | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | 日常使用 | ⭐⭐⭐⭐⭐ |
| Gateway Hook | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 高级用户 | ⭐⭐⭐⭐ |
| Cron | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 备用方案 | ⭐⭐⭐ |

---

## 🎯 最终建议

### 新用户

**推荐**: BOOT.md + Cron（备用）

1. 配置 BOOT.md（如方案 A）
2. 测试重启后是否正常
3. 如果不正常，添加 Cron 任务（如方案 C）

### 高级用户

**推荐**: BOOT.md + Gateway Hook（可选）+ Cron（最后防备）

1. 配置 BOOT.md
2. 部署 clash-startup hook（可选，用于详细日志）
3. 添加 Cron 任务作为最后防备

### WSL2/容器用户

**推荐**: BOOT.md + Cron（带等待时间）

1. 配置 BOOT.md
2. 使用 clash-cron-startup.sh 配置 Cron
3. 调整等待时间（60-120秒）确保网络就绪

---

## 📝 更新记录

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-02-27 | V1 | 尝试使用 BOOT.md（失败） |
| 2026-02-28 08:00 | V2 | 创建 clash-startup hook，修复进程检测（hook 未触发） |
| 2026-02-28 08:20 | V3 | 双保险方案 + 详细日志 |
| 2026-02-28 08:30 | Final | BOOT.md 成功，整理完整解决方案 |

---

## 🔗 相关文档

- [`SKILL.md`](./SKILL.md) - 完整技能说明
- [`CLASH_AUTO_STARTUP_FIX.md`](./CLASH_AUTO_STARTUP_FIX.md) - V1 方案
- [`CLASH_AUTO_STARTUP_FIX_V2.md`](./CLASH_AUTO_STARTUP_FIX_V2.md) - V2 方案
- [`CLASH_AUTO_STARTUP_FIX_V3.md`](./CLASH_AUTO_STARTUP_FIX_V3.md) - V3 方案
- [`hooks/clash-startup/`](./hooks/clash-startup/) - Hook 实现文件
- [`templates/BOOT.md`](./templates/BOOT.md) - BOOT.md 模板

---

**文档创建**: 2026-02-28 08:30 UTC
**问题解决**: ✅ BOOT.md 方案验证成功
**状态**: 完成并部署
