# Whisper 本地语音识别

基于 faster-whisper 的本地语音识别方案，支持多种模型大小。

## 安装

```powershell
# 使用 uv 创建虚拟环境并安装依赖
cd projects/whispertss
uv venv
.venv\Scripts\activate
uv pip install faster-whisper
```

## 使用

### 基本用法

```powershell
# 激活环境
.venv\Scripts\activate

# 转录音频（默认使用 large-v3 模型）
python transcribe.py audio.wav

# 使用 base 模型（更快，准确度稍低）
python transcribe.py audio.wav --model base

# 指定输出文件
python transcribe.py audio.wav --output result.txt
```

### 命令行参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--model, -m` | 模型名称 | large-v3 |
| `--device, -d` | 设备 (cpu/cuda) | cpu |
| `--compute-type, -c` | 计算类型 | int8 |
| `--language, -l` | 语言 (zh/en/auto) | zh |
| `--output, -o` | 输出文件 | - |
| `--no-vad` | 禁用 VAD | - |

### 可用模型

| 模型 | 参数量 | 内存占用 | 速度 | 准确度 |
|------|--------|----------|------|--------|
| tiny | 39M | ~1GB | 最快 | 一般 |
| base | 74M | ~1GB | 很快 | 较好 |
| small | 244M | ~2GB | 快 | 好 |
| medium | 769M | ~5GB | 中等 | 很好 |
| large-v3 | 1550M | ~10GB | 慢 | 最好 |

## 配置

编辑 `config.json` 修改默认配置：

```json
{
    "model": "large-v3",
    "device": "cpu",
    "compute_type": "int8",
    "language": "zh",
    "beam_size": 5,
    "vad_filter": true,
    "model_dir": "models"
}
```

## 本地模型

首次运行会自动下载模型到 HuggingFace 缓存目录。

如需使用本地模型文件，将模型放入 `models/` 目录：
```
models/
├── base/
├── small/
└── large-v3/
```

## 支持的音频格式

- wav (推荐)
- mp3
- m4a
- flac
- ogg
- webm

## GPU 加速

如果有 NVIDIA GPU 并安装了 CUDA：

```powershell
# 安装 GPU 版本 PyTorch
uv pip install torch --index-url https://download.pytorch.org/whl/cu121

# 使用 GPU
python transcribe.py audio.wav --device cuda --compute-type float16
```