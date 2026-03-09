# SKILL.md - Whisper 语音识别 Skill

## 描述

本地语音识别 Skill，使用 faster-whisper 将音频文件转换为简体中文文字。

## 能力

- 🎙️ 语音转文字（支持多种音频格式）
- 🔄 自动繁体转简体中文
- ⚡ 支持多种模型（tiny/base/small/medium/large-v3）
- 🔧 通过 config.json 切换模型
- 💻 纯本地运行，无需 API

## 使用方法

### 命令行

```bash
cd projects/whispertss
.venv\Scripts\activate
python transcribe.py audio.wav           # 输出识别文字
python transcribe.py audio.ogg -o out.txt # 保存到文件
```

### Python 调用

```python
from transcribe import transcribe

text = transcribe("audio.wav")  # 返回简体中文文字
```

### OpenClaw 集成

当用户发送语音消息时，自动调用此 Skill 进行转录。

## 模型下载

### 自动下载（首次运行）

首次运行时，faster-whisper 会自动从 HuggingFace 下载模型到本地：

```
models/
├── base/           # 约 150MB
│   ├── config.json
│   ├── model.bin
│   └── vocabulary.txt
```

**注意：** 自动下载需要网络访问 HuggingFace，中国大陆用户可能需要配置代理。

### 手动下载（网络受限时）

如果自动下载失败，可手动下载模型文件：

**方式一：使用镜像站下载**

```powershell
# 设置 HuggingFace 镜像（中国用户推荐）
$env:HF_ENDPOINT = "https://hf-mirror.com"

# 或在 config.json 中配置代理
# "proxy": "http://127.0.0.1:7890"
```

**方式二：直接下载模型文件**

1. 访问 HuggingFace 模型页面（需科学上网）或镜像站：
   - 官方：https://huggingface.co/Systran/faster-whisper-base
   - 镜像：https://hf-mirror.com/Systran/faster-whisper-base

2. 下载以下文件到 `models/base/` 目录：
   ```
   models/base/
   ├── config.json
   ├── model.bin
   ├── tokenizer.json
   └── vocabulary.txt
   ```

**方式三：使用 huggingface-cli 下载**

```powershell
# 安装 huggingface_hub
pip install huggingface_hub

# 设置镜像（可选）
$env:HF_ENDPOINT = "https://hf-mirror.com"

# 下载模型
huggingface-cli download Systran/faster-whisper-base --local-dir models/base
```

### 各模型下载地址

| 模型 | 大小 | HuggingFace 地址 | 镜像地址 |
|------|------|------------------|----------|
| tiny | ~40MB | `Systran/faster-whisper-tiny` | `https://hf-mirror.com/Systran/faster-whisper-tiny` |
| base | ~150MB | `Systran/faster-whisper-base` | `https://hf-mirror.com/Systran/faster-whisper-base` |
| small | ~500MB | `Systran/faster-whisper-small` | `https://hf-mirror.com/Systran/faster-whisper-small` |
| medium | ~1.5GB | `Systran/faster-whisper-medium` | `https://hf-mirror.com/Systran/faster-whisper-medium` |
| large-v3 | ~3GB | `Systran/faster-whisper-large-v3` | `https://hf-mirror.com/Systran/faster-whisper-large-v3` |

### 切换模型

编辑 `config.json`：

```json
{
    "model": "small",  // 改为其他模型：tiny/base/small/medium/large-v3
    "model_dir": "models"
}
```

或在代码中指定：

```bash
python transcribe.py audio.wav --model small
```

### 代理配置

如果网络需要代理，在 `config.json` 中添加：

```json
{
    "model": "base",
    "proxy": "http://127.0.0.1:7890"
}
```

或设置环境变量：

```powershell
$env:HTTP_PROXY = "http://127.0.0.1:7890"
$env:HTTPS_PROXY = "http://127.0.0.1:7890"
```

## 配置

编辑 `config.json` 切换模型和设置：

```json
{
    "model": "base",           // 模型：tiny/base/small/medium/large-v3
    "device": "cpu",           // 设备：cpu/cuda
    "compute_type": "int8",    // 计算类型：int8/float16/float32
    "language": "zh",          // 语言：zh/en/auto
    "vad_filter": true,        // 静音过滤
    "model_dir": "models",     // 模型存放目录
    "proxy": "",               // 代理地址（可选）
    "convert_to_simplified": true  // 繁体转简体
}
```

## 模型对比

| 模型 | 参数量 | 内存 | 速度 | 准确度 |
|------|--------|------|------|--------|
| tiny | 39M | ~1GB | 最快 | 一般 |
| base | 74M | ~1GB | 很快 | 较好 |
| small | 244M | ~2GB | 快 | 好 |
| medium | 769M | ~5GB | 中等 | 很好 |
| large-v3 | 1550M | ~10GB | 慢 | 最好 |

**推荐：base 模型（默认）** - 速度快、准确度高、资源占用低

## 文件结构

```
whispertss/
├── SKILL.md          # 本文件
├── transcribe.py     # 主脚本
├── config.json       # 配置文件
├── pyproject.toml    # 项目定义
├── README.md         # 详细文档
├── models/           # 模型存放目录
│   └── base/         # base 模型文件
└── .venv/            # 虚拟环境 (uv)
```

## 依赖

- Python >= 3.10
- faster-whisper >= 1.0.0
- opencc >= 1.1.0 (繁简转换)

## 安装

```bash
cd whispertss
uv venv
.venv\Scripts\activate  # Windows
uv pip install faster-whisper opencc
```

## 输入格式

支持常见音频格式：
- wav (推荐)
- mp3
- m4a
- ogg (Telegram 语音)
- flac
- webm

## 输出

- **纯文字**（已转为简体中文）
- 可选保存到文件

## 示例

```bash
# 转录 Telegram 语音
python transcribe.py voice.ogg
# 输出: 你好世界

# 使用大模型提高准确度
python transcribe.py audio.wav --model large-v3

# 保存结果
python transcribe.py audio.mp3 -o transcript.txt
```

## 故障排查

| 问题 | 解决方案 |
|------|----------|
| 模型下载失败 | 配置代理或使用 hf-mirror.com 镜像 |
| 下载速度慢 | 使用镜像站或手动下载 |
| 找不到模型 | 检查 `models/` 目录是否存在模型文件 |
| 内存不足 | 使用更小的模型（tiny/base） |
| GPU 无法使用 | 检查 CUDA 安装，或改用 `device: cpu` |

## 注意事项

- 首次运行会自动下载模型（约 150MB for base）
- 如需使用 GPU，设置 `"device": "cuda"`
- 繁体中文会自动转换为简体中文