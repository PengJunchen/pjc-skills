#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Whisper 本地语音识别 - 简化输出

使用 faster-whisper 进行本地语音识别，只输出识别文字。
"""

import os
import sys
import json
import argparse
from pathlib import Path


def setup_proxy():
    """设置代理"""
    proxy = os.environ.get("HTTP_PROXY") or os.environ.get("HTTPS_PROXY")
    if not proxy:
        config_file = Path(__file__).parent / "config.json"
        if config_file.exists():
            with open(config_file, "r", encoding="utf-8") as f:
                config = json.load(f)
            if config.get("proxy"):
                os.environ["HTTP_PROXY"] = config["proxy"]
                os.environ["HTTPS_PROXY"] = config["proxy"]
                os.environ["HF_ENDPOINT"] = "https://hf-mirror.com"


def load_config() -> dict:
    """加载配置"""
    config_file = Path(__file__).parent / "config.json"
    if config_file.exists():
        with open(config_file, "r", encoding="utf-8") as f:
            return json.load(f)
    return {
        "model": "base",
        "device": "cpu", 
        "compute_type": "int8",
        "language": "zh",
        "model_dir": "models",
        "convert_to_simplified": True
    }


def transcribe(audio_path: str, quiet: bool = False) -> str:
    """
    转录音频，返回纯文字
    
    Args:
        audio_path: 音频文件路径
        quiet: 是否静默模式（不打印任何信息）
    
    Returns:
        识别的文字（已转为简体）
    """
    from faster_whisper import WhisperModel
    
    config = load_config()
    
    if not os.path.exists(audio_path):
        raise FileNotFoundError(f"音频文件不存在: {audio_path}")
    
    # 检查本地模型
    model_dir = Path(__file__).parent / config.get("model_dir", "models")
    model_path = model_dir / config["model"]
    if model_path.exists():
        model_path = str(model_path)
    else:
        model_path = config["model"]
    
    # 加载模型
    model = WhisperModel(
        model_path,
        device=config.get("device", "cpu"),
        compute_type=config.get("compute_type", "int8"),
    )
    
    # 转录
    segments, _ = model.transcribe(
        audio_path,
        language=config.get("language", "zh"),
        vad_filter=config.get("vad_filter", True),
    )
    
    # 收集文字
    text = " ".join(s.text for s in segments)
    
    # 繁体转简体
    if config.get("convert_to_simplified", True):
        try:
            from opencc import OpenCC
            cc = OpenCC('t2s')
            text = cc.convert(text)
        except ImportError:
            pass
    
    return text.strip()


def main():
    parser = argparse.ArgumentParser(description="Whisper 语音识别")
    parser.add_argument("audio", help="音频文件路径")
    parser.add_argument("--quiet", "-q", action="store_true", help="静默模式，只输出文字")
    parser.add_argument("--output", "-o", help="保存到文件")
    
    args = parser.parse_args()
    
    try:
        setup_proxy()
        text = transcribe(args.audio, quiet=args.quiet)
        
        # 只输出纯文字
        print(text)
        
        if args.output:
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(text)
                
    except Exception as e:
        print(f"错误: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()