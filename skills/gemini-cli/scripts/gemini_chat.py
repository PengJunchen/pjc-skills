#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gemini 对话脚本

CLI:
    py gemini_chat.py --message "你好"
    py gemini_chat.py --status
    py gemini_chat.py --new

Python API:
    from gemini_client import GeminiClient
    async with GeminiClient(port=18800) as client:
        response = await client.chat("你好")
        print(response.text)
"""
import asyncio
import json
import sys
import argparse

# 添加 lib 到路径
sys.path.insert(0, __file__.replace('\\scripts\\gemini_chat.py', '\\lib'))

from gemini_client import GeminiClient, chat, get_status


async def main():
    parser = argparse.ArgumentParser(
        description='Gemini 对话',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
    py gemini_chat.py --message "什么是量子计算?"
    py gemini_chat.py --message "写一首诗" --wait 20
    py gemini_chat.py --status
    py gemini_chat.py --new

环境准备:
    1. 启动浏览器: browser(action="start", profile="chrome")
    2. 打开 Gemini: browser(action="open", url="https://gemini.google.com/app")
    3. 登录 Google 账号
        """
    )
    parser.add_argument('--message', '-m', help='发送的消息')
    parser.add_argument('--port', type=int, default=18800, help='CDP 端口')
    parser.add_argument('--wait', '-w', type=float, default=15, help='等待响应时间(秒)')
    parser.add_argument('--status', action='store_true', help='查看状态')
    parser.add_argument('--new', action='store_true', help='开始新对话')
    parser.add_argument('--output', '-o', help='输出文件路径')
    
    args = parser.parse_args()
    
    # 查看状态
    if args.status:
        status = await get_status(args.port)
        print(json.dumps(status, indent=2, ensure_ascii=False))
        return
    
    # 开始新对话
    if args.new:
        async with GeminiClient(args.port) as client:
            if await client.new_chat():
                print("✅ 已开始新对话")
            else:
                print("❌ 无法开始新对话")
        return
    
    # 发送消息
    if not args.message:
        parser.error("--message 是必需的 (或使用 --status/--new)")
    
    async with GeminiClient(args.port) as client:
        result = await client.chat(args.message, wait_seconds=args.wait)
        
        if result.success:
            print(result.text)
            
            if args.output:
                with open(args.output, 'w', encoding='utf-8') as f:
                    f.write(result.text)
                print(f"\n已保存到: {args.output}")
        else:
            print(f"❌ 错误: {result.error}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())