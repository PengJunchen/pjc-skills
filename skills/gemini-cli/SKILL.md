# SKILL.md - Gemini CLI

Gemini AI 操作技能，通过 Chrome DevTools Protocol (CDP) 实现，继承 Chrome 登录状态。

## 技能列表

| 技能 | 描述 | 命令 |
|------|------|------|
| image | 图片生成 | `gemini image --prompt "描述" --style 风格` |
| chat | 对话交互 | `gemini chat "消息"` |
| status | 状态检查 | `gemini status` |

---

## 环境准备

### 1. 检测与安装 Chrome

**检测 Chrome：**

```bash
# Windows
where chrome
# 或
"C:\Program Files\Google\Chrome\Application\chrome.exe" --version

# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version

# Linux
google-chrome --version
# 或
chromium-browser --version
```

**如果未检测到 Chrome，请安装：**

| 平台 | 安装方式 |
|------|----------|
| Windows | [下载 Chrome 安装包](https://www.google.com/chrome/) 或 `winget install Google.Chrome` |
| macOS | `brew install --cask google-chrome` 或 [官网下载](https://www.google.com/chrome/) |
| Linux (Debian/Ubuntu) | `sudo apt install google-chrome-stable` |
| Linux (Arch) | `sudo pacman -S google-chrome` |
| Linux (Fedora) | `sudo dnf install google-chrome-stable` |

### 2. 检测与安装 Python

**检测 Python（需要 3.7+）：**

```bash
# 检查 Python 版本
python --version
# 或
python3 --version

# 检查 pip
pip --version
```

**如果未检测到 Python，请安装：**

| 平台 | 安装方式 |
|------|----------|
| Windows | [下载 Python](https://www.python.org/downloads/) 或 `winget install Python.Python.3.12` |
| macOS | `brew install python@3.12` |
| Linux (Debian/Ubuntu) | `sudo apt install python3 python3-pip` |
| Linux (Arch) | `sudo pacman -S python python-pip` |
| Linux (Fedora) | `sudo dnf install python3 python3-pip` |

### 3. 安装依赖

```bash
pip install websockets
```

**如果 pip 命令不可用：**

```bash
# 使用 python -m pip
python -m pip install websockets

# 或使用 pip3
pip3 install websockets
```

### 4. 启动浏览器

```python
# OpenClaw 会话中执行
browser(action="start", profile="chrome")
browser(action="open", url="https://gemini.google.com/app")
```

### 5. 登录 Google 账号

**重要：首次使用必须在 Chrome 中登录 Google 账号！**

访问 https://accounts.google.com 登录，然后访问 Gemini 确认可用。

---

## 技能 1: 图片生成 (image)

### CLI 使用

```bash
# 生成图片
py skills/gemini-cli/scripts/gemini_image.py --prompt "一只可爱的猫" --style 油画

# 查看状态
py skills/gemini-cli/scripts/gemini_image.py --status

# 列出可用风格
py skills/gemini-cli/scripts/gemini_image.py --list-styles

# 自定义等待时间
py skills/gemini-cli/scripts/gemini_image.py --prompt "山水画" --wait 50
```

### Python API

```python
import sys
sys.path.insert(0, 'skills/gemini-cli/lib')
from gemini_client import GeminiClient

async with GeminiClient(port=18800) as client:
    # 生成图片
    result = await client.generate_image(
        prompt="一只可爱的橘猫",
        style="油画",
        wait_seconds=40
    )
    
    if result.success:
        for img in result.images:
            print(f"图片: {img['width']}x{img['height']}")
            print(f"URL: {img['url']}")
```

### 可用风格

```
单色, 色块, 跑道, 孔版印刷, 绚彩, 哥特风黏土,
轰动, 沙龙, 素描, 电影效果, 蒸汽朋克, 日出,
神话斗士, 超现实, 幽暗, 珐琅胸针, Cyborg,
柔美人像, 怀旧卡通, 油画
```

---

## 技能 2: 对话交互 (chat)

### CLI 使用

```bash
# 发送消息
py skills/gemini-cli/scripts/gemini_chat.py --message "什么是量子计算?"

# 查看状态
py skills/gemini-cli/scripts/gemini_chat.py --status

# 开始新对话
py skills/gemini-cli/scripts/gemini_chat.py --new
```

### Python API

```python
import sys
sys.path.insert(0, 'skills/gemini-cli/lib')
from gemini_client import GeminiClient

async with GeminiClient(port=18800) as client:
    # 发送消息
    response = await client.chat("你好，请介绍一下自己")
    print(response)
    
    # 开始新对话
    await client.new_chat()
    
    # 获取对话文本
    text = await client.get_conversation_text()
```

---

## 工作流程

```
┌─────────────────────────────────────┐
│ 1. 检查代理 (如需要)                 │
│    访问 Google 可能需要代理          │
└────────────────┬────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│ 2. 启动浏览器                        │
│    browser(action="start",          │
│            profile="chrome")         │
└────────────────┬────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│ 3. 打开 Gemini                       │
│    browser(action="open",            │
│            url="https://gemini...")  │
└────────────────┬────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│ 4. 确认登录状态                      │
│    页面应显示用户头像/姓名            │
└────────────────┬────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│ 5. 运行技能脚本                      │
│    py gemini_image.py --prompt      │
│    py gemini_chat.py --message      │
└────────────────┬────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│ 6. 获取结果                          │
│    图片 URL / 对话文本               │
└─────────────────────────────────────┘
```

---

## 文件结构

```
skills/gemini-cli/
├── SKILL.md                 # 本文档
├── scripts/
│   ├── gemini_image.py      # 图片生成脚本
│   └── gemini_chat.py       # 对话脚本
└── lib/
    ├── cdp_client.py        # CDP 底层客户端
    └── gemini_client.py     # Gemini 客户端封装
```

---

## CDP 配置详解

### 方式一：通过 OpenClaw 启动（推荐）

```python
# 在 OpenClaw 会话中执行
browser(action="start", profile="chrome")
browser(action="open", url="https://gemini.google.com/app")

# 获取 CDP 端口
status = browser(action="status")
# 返回: {"cdpPort": 18800, ...}
```

### 方式二：手动启动 Chrome

```bash
# Windows
"C:\Program Files\Google\Chrome\Application\chrome.exe" \
  --remote-debugging-port=18800 \
  --user-data-dir="C:\Users\YourName\AppData\Local\Google\Chrome\User Data"

# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=18800

# Linux
google-chrome --remote-debugging-port=18800
```

### 端口获取

```python
import urllib.request
import json

# HTTP 方式获取端口信息
with urllib.request.urlopen("http://localhost:18800/json/version") as r:
    version = json.loads(r.read())
    print(f"Browser: {version.get('Browser')}")
    print(f"WebSocket: {version.get('webSocketDebuggerUrl')}")

# 获取所有页面
with urllib.request.urlopen("http://localhost:18800/json/list") as r:
    pages = json.loads(r.read())
```

### 页面选择

```python
# 方式一：精确匹配首页
for p in pages:
    if p.get("url") == "https://gemini.google.com/app":
        page_id = p["id"]
        ws_url = p["webSocketDebuggerUrl"]
        break

# 方式二：模糊匹配
for p in pages:
    if "gemini.google.com" in p.get("url", ""):
        page_id = p["id"]
        break
```

### WebSocket 连接

```python
import websockets
import json

async with websockets.connect(ws_url) as ws:
    # 启用 Runtime 域
    await ws.send(json.dumps({"id": 1, "method": "Runtime.enable"}))
    response = json.loads(await ws.recv())
```

---

## CDP 通用经验

### 1. JavaScript 执行

```python
# 执行并获取返回值
result = await client.eval_js("document.title")

# 执行复杂逻辑
result = await client.eval_js("""
    (() => {
        const el = document.querySelector('textarea');
        el.value = 'Hello';
        el.dispatchEvent(new Event('input', { bubbles: true }));
        return el.value;
    })()
""")
```

### 2. 输入处理

```python
# 设置输入框值
escaped = text.replace("'", "\\'").replace("\n", "\\n")
await client.eval_js(f"""
    const el = document.querySelector('textarea');
    if (el) {{
        el.value = '{escaped}';
        el.dispatchEvent(new Event('input', {{ bubbles: true }}));
    }}
""")

# 按 Enter
await client._cmd("Input.dispatchKeyEvent", {
    "type": "keyDown",
    "key": "Enter",
    "windowsVirtualKeyCode": 13
})
await client._cmd("Input.dispatchKeyEvent", {
    "type": "keyUp",
    "key": "Enter",
    "windowsVirtualKeyCode": 13
})
```

### 3. 等待策略

```python
# 固定等待（简单但不精确）
await asyncio.sleep(3)

# 条件等待（更可靠）
for _ in range(30):
    result = await client.eval_js("/* 检查条件 */")
    if result:
        break
    await asyncio.sleep(1)
```

### 4. 错误处理

```python
import urllib.error

try:
    with urllib.request.urlopen(f"http://localhost:{port}/json/list", timeout=5) as r:
        pages = json.loads(r.read())
except urllib.error.URLError:
    raise ConnectionError(
        f"CDP 未启动，请先运行:\n"
        f"  browser(action='start', profile='chrome')"
    )
```

---

## 常见问题

### Q: CDP 连接失败？

```
检查：
1. 浏览器是否启动: browser(action="status")
2. 端口是否正确: 默认 18800
3. 防火墙是否阻止
```

### Q: 未检测到登录？

```
原因：
1. 未在 Chrome 中登录 Google 账号
2. profile 参数错误

解决：
1. 手动访问 accounts.google.com 登录
2. 确保 profile="chrome"
```

### Q: 图片生成超时？

```
建议：
1. 增加等待时间: --wait 50
2. 检查网络连接
3. 确认代理开启 (如需要)
```

---

## 更新日志

- **2026-03-26**: 创建 gemini-cli 技能，整合图片生成和对话功能