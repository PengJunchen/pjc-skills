#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gemini Client - Gemini CDP 操作客户端

支持：
- 图片生成
- 对话交互
- 会话管理

依赖:
    pip install websockets

使用:
    from gemini_client import GeminiClient
    
    async with GeminiClient(port=18800) as client:
        # 图片生成
        result = await client.generate_image("一只可爱的猫", style="油画")
        
        # 对话
        response = await client.chat("你好")
"""
import asyncio
import json
import sys
from typing import Optional, Dict, List, Any
from dataclasses import dataclass
from datetime import datetime

# 强制 UTF-8 输出
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

from .cdp_client import CDPClient, CDPError, get_gemini_page, check_cdp_available


# ========== 数据类 ==========

@dataclass
class ImageResult:
    """图片生成结果"""
    success: bool
    images: List[Dict[str, Any]]
    error: Optional[str] = None
    prompt: str = ""
    style: str = ""
    timestamp: str = ""


@dataclass
class ChatResult:
    """对话结果"""
    success: bool
    text: str
    error: Optional[str] = None


# ========== Gemini 客户端 ==========

class GeminiClient:
    """Gemini CDP 客户端"""
    
    GEMINI_URL = "https://gemini.google.com/app"
    
    AVAILABLE_STYLES = [
        "单色", "色块", "跑道", "孔版印刷", "绚彩", "哥特风黏土",
        "轰动", "沙龙", "素描", "电影效果", "蒸汽朋克", "日出",
        "神话斗士", "超现实", "幽暗", "珐琅胸针", "Cyborg",
        "柔美人像", "怀旧卡通", "油画"
    ]
    
    def __init__(self, port: int = 18800):
        self.port = port
        self.client: Optional[CDPClient] = None
        self.page_id: Optional[str] = None
    
    async def __aenter__(self):
        await self.connect()
        return self
    
    async def __aexit__(self, *args):
        await self.close()
    
    # ========== 连接管理 ==========
    
    async def connect(self) -> bool:
        """连接到 Gemini 页面"""
        # 检查 CDP
        if not check_cdp_available(self.port):
            raise CDPError(
                f"CDP not available at port {self.port}.\n"
                "Please start browser:\n"
                "  browser(action='start', profile='chrome')\n"
                "  browser(action='open', url='https://gemini.google.com/app')"
            )
        
        # 获取页面
        self.page_id = get_gemini_page(self.port)
        if not self.page_id:
            raise CDPError(
                "No Gemini page found.\n"
                "Please open:\n"
                "  browser(action='open', url='https://gemini.google.com/app')"
            )
        
        # 连接
        self.client = CDPClient(self.port)
        await self.client.connect(self.page_id)
        await self.client.enable("Runtime", "Input")
        
        return True
    
    async def close(self):
        """关闭连接"""
        if self.client:
            await self.client.close()
            self.client = None
    
    # ========== 页面状态 ==========
    
    async def get_title(self) -> str:
        """获取页面标题"""
        return await self.client.eval_js("document.title") or ""
    
    async def get_url(self) -> str:
        """获取当前 URL"""
        return await self.client.eval_js("window.location.href") or ""
    
    async def is_logged_in(self) -> bool:
        """检查是否已登录"""
        result = await self.client.eval_js("""
            !!document.querySelector('button[aria-label*="Google"]') ||
            !!document.querySelector('button[aria-label*="账号"]') ||
            !!document.querySelector('[aria-label*="Junchen"]') ||
            !!document.querySelector('[aria-label*="Peng"]')
        """)
        return bool(result)
    
    async def get_user_info(self) -> Optional[str]:
        """获取用户信息"""
        return await self.client.eval_js("""
            (() => {
                const btn = document.querySelector('button[aria-label]');
                if (btn) {
                    const label = btn.getAttribute('aria-label');
                    if (label && (label.includes('Google') || label.includes('账号'))) {
                        return label;
                    }
                }
                return null;
            })()
        """)
    
    async def get_status(self) -> Dict[str, Any]:
        """获取状态信息"""
        try:
            return {
                "connected": True,
                "logged_in": await self.is_logged_in(),
                "user": await self.get_user_info(),
                "url": await self.get_url(),
                "title": await self.get_title(),
                "port": self.port
            }
        except Exception as e:
            return {
                "connected": False,
                "error": str(e),
                "port": self.port
            }
    
    # ========== 内部方法 ==========
    
    async def _ensure_home_page(self):
        """确保在首页"""
        current_url = await self.get_url()
        if "/app/" in current_url and len(current_url) > len(self.GEMINI_URL):
            await self.client.eval_js(f"window.location.href = '{self.GEMINI_URL}'")
            await asyncio.sleep(3)
    
    async def _click_make_image(self) -> bool:
        """点击制作图片按钮"""
        return await self.client.eval_js("""
            (() => {
                const btns = document.querySelectorAll('button');
                for (const btn of btns) {
                    if (btn.textContent.includes('制作图片') || btn.textContent.includes('🖼️')) {
                        btn.click();
                        return true;
                    }
                }
                return false;
            })()
        """) or False
    
    async def _select_style(self, style: str) -> bool:
        """选择风格"""
        return await self.client.eval_js(f"""
            (() => {{
                const items = document.querySelectorAll('[role="button"], [cursor="pointer"], button');
                for (const item of items) {{
                    if (item.textContent.includes('{style}')) {{
                        item.click();
                        return true;
                    }}
                }}
                return false;
            }})()
        """) or False
    
    async def _set_input_value(self, text: str) -> bool:
        """设置输入框值"""
        escaped = text.replace("'", "\\'").replace("\n", "\\n")
        return await self.client.eval_js(f"""
            (() => {{
                const textarea = document.querySelector('textarea');
                const contentEditable = document.querySelector('[contenteditable="true"]');
                if (textarea) {{
                    textarea.value = '{escaped}';
                    textarea.dispatchEvent(new Event('input', {{ bubbles: true }}));
                    return true;
                }}
                if (contentEditable) {{
                    contentEditable.innerText = '{escaped}';
                    contentEditable.dispatchEvent(new Event('input', {{ bubbles: true }}));
                    return true;
                }}
                return false;
            }})()
        """) or False
    
    async def _press_enter(self):
        """按 Enter 发送"""
        await self.client._cmd("Input.dispatchKeyEvent", {
            "type": "keyDown",
            "key": "Enter",
            "code": "Enter",
            "windowsVirtualKeyCode": 13
        })
        await self.client._cmd("Input.dispatchKeyEvent", {
            "type": "keyUp",
            "key": "Enter",
            "code": "Enter",
            "windowsVirtualKeyCode": 13
        })
    
    async def _get_generated_images(self) -> List[Dict]:
        """获取生成的图片"""
        return await self.client.eval_js("""
            (() => {
                const imgs = document.querySelectorAll('img');
                const urls = [];
                imgs.forEach(img => {
                    if (img.src && 
                        (img.src.includes('googleusercontent.com') || img.src.includes('ggpht.com')) &&
                        img.naturalWidth > 100) {
                        urls.push({
                            url: img.src,
                            width: img.naturalWidth,
                            height: img.naturalHeight
                        });
                    }
                });
                return urls;
            })()
        """) or []
    
    # ========== 图片生成 ==========
    
    async def generate_image(
        self,
        prompt: str,
        style: str = None,
        wait_seconds: float = 40.0,
        verbose: bool = True
    ) -> ImageResult:
        """生成图片
        
        Args:
            prompt: 图片描述
            style: 图片风格（可选）
            wait_seconds: 等待时间（建议 30-50 秒）
            verbose: 是否输出详细信息
        
        Returns:
            ImageResult: 生成结果
        """
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        def log(msg: str):
            if verbose:
                print(msg)
        
        # 检查登录
        if not await self.is_logged_in():
            return ImageResult(
                success=False,
                images=[],
                error="未登录 Google 账号",
                prompt=prompt,
                style=style or "",
                timestamp=timestamp
            )
        
        log(f"[1/7] 用户已登录: {await self.get_user_info()}")
        
        # 确保首页
        log("[2/7] 确保在 Gemini 首页...")
        await self._ensure_home_page()
        await asyncio.sleep(1)
        
        # 点击制作图片
        log("[3/7] 点击'制作图片'按钮...")
        if not await self._click_make_image():
            return ImageResult(
                success=False,
                images=[],
                error="未找到'制作图片'按钮",
                prompt=prompt,
                style=style or "",
                timestamp=timestamp
            )
        await asyncio.sleep(2)
        
        # 选择风格
        if style:
            log(f"[4/7] 选择风格: {style}...")
            await self._select_style(style)
            await asyncio.sleep(1)
        else:
            log("[4/7] 使用默认风格")
        
        # 输入提示词
        log(f"[5/7] 输入提示词: {prompt}")
        if not await self._set_input_value(prompt):
            return ImageResult(
                success=False,
                images=[],
                error="无法设置提示词",
                prompt=prompt,
                style=style or "",
                timestamp=timestamp
            )
        await asyncio.sleep(1)
        
        # 发送
        log("[6/7] 发送请求...")
        await self._press_enter()
        
        # 等待生成
        log(f"[7/7] 等待图片生成 ({wait_seconds}秒)...")
        await asyncio.sleep(wait_seconds)
        
        # 获取结果
        images = await self._get_generated_images()
        
        if images:
            log(f"\n✅ 成功生成 {len(images)} 张图片:")
            for i, img in enumerate(images, 1):
                log(f"   {i}. {img['width']}x{img['height']}")
                log(f"      {img['url'][:60]}...")
        else:
            log("\n⚠️ 未检测到生成的图片")
        
        return ImageResult(
            success=len(images) > 0,
            images=images,
            error=None if images else "图片生成超时或失败",
            prompt=prompt,
            style=style or "",
            timestamp=timestamp
        )
    
    # ========== 对话交互 ==========
    
    async def chat(self, message: str, wait_seconds: float = 15.0) -> ChatResult:
        """发送消息
        
        Args:
            message: 消息内容
            wait_seconds: 等待响应时间
        
        Returns:
            ChatResult: 对话结果
        """
        # 检查登录
        if not await self.is_logged_in():
            return ChatResult(
                success=False,
                text="",
                error="未登录 Google 账号"
            )
        
        # 设置输入
        if not await self._set_input_value(message):
            return ChatResult(
                success=False,
                text="",
                error="无法设置消息"
            )
        
        # 发送
        await self._press_enter()
        
        # 等待响应
        await asyncio.sleep(wait_seconds)
        
        # 获取响应
        response = await self.client.eval_js("""
            (() => {
                const main = document.querySelector('main');
                return main ? main.innerText : '';
            })()
        """) or ""
        
        return ChatResult(
            success=True,
            text=response
        )
    
    async def new_chat(self) -> bool:
        """开始新对话"""
        return await self.client.eval_js("""
            (() => {
                const btns = document.querySelectorAll('a[href="/app"], button');
                for (const btn of btns) {
                    if (btn.textContent.includes('新对话') || 
                        btn.textContent.includes('New chat')) {
                        btn.click();
                        return true;
                    }
                }
                return false;
            })()
        """) or False
    
    async def get_conversation_text(self) -> str:
        """获取当前对话文本"""
        return await self.client.eval_js("""
            document.querySelector('main')?.innerText || ''
        """) or ""


# ========== 便捷函数 ==========

async def generate_image(
    prompt: str,
    style: str = None,
    port: int = 18800,
    wait_seconds: float = 40.0
) -> ImageResult:
    """快速生成图片"""
    async with GeminiClient(port) as client:
        return await client.generate_image(prompt, style, wait_seconds)


async def chat(message: str, port: int = 18800) -> str:
    """快速发送消息"""
    async with GeminiClient(port) as client:
        result = await client.chat(message)
        if not result.success:
            raise Exception(result.error)
        return result.text


async def get_status(port: int = 18800) -> Dict[str, Any]:
    """获取 Gemini 状态"""
    try:
        async with GeminiClient(port) as client:
            return await client.get_status()
    except Exception as e:
        return {
            "connected": False,
            "error": str(e),
            "port": port
        }