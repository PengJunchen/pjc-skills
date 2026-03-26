#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gemini 图片生成脚本

CLI:
    py gemini_image.py --prompt "一只猫" --style 油画
    py gemini_image.py --status
    py gemini_image.py --list-styles

Python API:
    from gemini_client import GeminiClient
    async with GeminiClient(port=18800) as client:
        result = await client.generate_image("一只猫", style="油画")
"""
import asyncio
import json
import sys
import argparse

# 添加 lib 到路径
sys.path.insert(0, __file__.replace('\\scripts\\gemini_image.py', '\\lib'))

from gemini_client import GeminiClient, generate_image, get_status


async def main():
    parser = argparse.ArgumentParser(
        description='Gemini 图片生成',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
    py gemini_image.py --prompt "一只可爱的猫" --style 油画
    py gemini_image.py --prompt "山水画" --wait 50
    py gemini_image.py --status
    py gemini_image.py --list-styles

环境准备:
    1. 启动浏览器: browser(action="start", profile="chrome")
    2. 打开 Gemini: browser(action="open", url="https://gemini.google.com/app")
    3. 登录 Google 账号
        """
    )
    parser.add_argument('--prompt', '-p', help='图片描述')
    parser.add_argument('--style', '-s', choices=GeminiClient.AVAILABLE_STYLES,
                       help='图片风格')
    parser.add_argument('--port', type=int, default=18800, help='CDP 端口')
    parser.add_argument('--wait', '-w', type=float, default=40, help='等待时间(秒)')
    parser.add_argument('--status', action='store_true', help='查看状态')
    parser.add_argument('--list-styles', action='store_true', help='列出所有风格')
    parser.add_argument('--output', '-o', help='输出 JSON 文件路径')
    
    args = parser.parse_args()
    
    # 列出风格
    if args.list_styles:
        print("可用风格:")
        for i, style in enumerate(GeminiClient.AVAILABLE_STYLES, 1):
            print(f"  {i:2}. {style}")
        return
    
    # 查看状态
    if args.status:
        status = await get_status(args.port)
        print(json.dumps(status, indent=2, ensure_ascii=False))
        return
    
    # 生成图片
    if not args.prompt:
        parser.error("--prompt 是必需的 (或使用 --status/--list-styles)")
    
    async with GeminiClient(args.port) as client:
        result = await client.generate_image(
            prompt=args.prompt,
            style=args.style,
            wait_seconds=args.wait,
            verbose=True
        )
        
        # 输出结果
        output = {
            "success": result.success,
            "images": result.images,
            "error": result.error,
            "prompt": result.prompt,
            "style": result.style,
            "timestamp": result.timestamp
        }
        
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                json.dump(output, f, indent=2, ensure_ascii=False)
            print(f"\n结果已保存到: {args.output}")
        else:
            print("\n" + "=" * 50)
            print(json.dumps(output, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    asyncio.run(main())