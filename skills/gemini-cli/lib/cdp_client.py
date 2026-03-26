#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CDP Client - 轻量级 Chrome DevTools Protocol 客户端

使用方法:
    from cdp_client import CDPClient, get_gemini_page
    
    async with CDPClient(port=18800) as client:
        page_id = get_gemini_page(client.port)
        await client.connect(page_id)
        
        result = await client.eval_js("document.title")
        print(result)
"""
import asyncio
import json
import urllib.request
import urllib.error
import websockets
from typing import Optional, Dict, Any, List


class CDPError(Exception):
    """CDP 错误"""
    pass


class CDPClient:
    """轻量级 CDP 客户端"""
    
    DEFAULT_PORT = 18800
    
    def __init__(self, port: int = None):
        self.port = port or self.DEFAULT_PORT
        self.ws: Optional[websockets.WebSocketClientProtocol] = None
        self.msg_id = 0
    
    async def __aenter__(self):
        return self
    
    async def __aexit__(self, *args):
        await self.close()
    
    async def connect(self, page_id: str):
        """连接到指定页面"""
        url = f"ws://localhost:{self.port}/devtools/page/{page_id}"
        try:
            self.ws = await websockets.connect(url)
        except Exception as e:
            raise CDPError(f"Cannot connect to page: {e}")
        return self
    
    async def _cmd(self, method: str, params: Dict = None) -> Dict:
        """发送 CDP 命令"""
        if not self.ws:
            raise RuntimeError("Not connected. Call connect() first.")
        
        self.msg_id += 1
        payload = {"id": self.msg_id, "method": method}
        if params:
            payload["params"] = params
        
        await self.ws.send(json.dumps(payload, ensure_ascii=False))
        
        # Wait for matching response
        while True:
            msg = json.loads(await self.ws.recv())
            if msg.get("id") == self.msg_id:
                if "error" in msg:
                    raise CDPError(msg["error"].get("message", "CDP error"))
                return msg
    
    async def enable(self, *domains: str):
        """启用域"""
        for domain in domains:
            try:
                await self._cmd(f"{domain}.enable")
            except CDPError:
                pass  # Domain may not be available
    
    async def eval_js(self, code: str, return_value: bool = True) -> Any:
        """执行 JavaScript"""
        result = await self._cmd("Runtime.evaluate", {
            "expression": code,
            "returnByValue": return_value
        })
        return result.get("result", {}).get("result", {}).get("value")
    
    async def type_text(self, text: str, selector: str = None):
        """输入文字"""
        escaped = text.replace("'", "\\'").replace("\n", "\\n")
        if selector:
            await self.eval_js(f"""
                const el = document.querySelector('{selector}');
                if (el) {{
                    el.focus();
                    if (el.tagName === 'TEXTAREA' || el.tagName === 'INPUT') {{
                        el.value = '{escaped}';
                    }} else {{
                        el.innerText = '{escaped}';
                    }}
                    el.dispatchEvent(new Event('input', {{ bubbles: true }}));
                }}
            """)
    
    async def press_key(self, key: str, code: str = None, vk: int = None):
        """按键"""
        params = {"type": "keyDown", "key": key}
        if code:
            params["code"] = code
        if vk:
            params["windowsVirtualKeyCode"] = vk
        
        await self._cmd("Input.dispatchKeyEvent", params)
        params["type"] = "keyUp"
        await self._cmd("Input.dispatchKeyEvent", params)
    
    async def press_enter(self):
        """按 Enter"""
        await self.press_key("Enter", "Enter", 13)
    
    async def click(self, selector: str):
        """点击元素"""
        await self.eval_js(f"document.querySelector('{selector}')?.click()")
    
    async def get_text(self, selector: str) -> str:
        """获取元素文本"""
        return await self.eval_js(f"document.querySelector('{selector}')?.innerText || ''") or ""
    
    async def wait_for(self, condition: str, timeout: float = 30.0) -> bool:
        """等待条件满足"""
        start = asyncio.get_event_loop().time()
        while asyncio.get_event_loop().time() - start < timeout:
            result = await self.eval_js(condition)
            if result:
                return True
            await asyncio.sleep(0.5)
        return False
    
    async def close(self):
        """关闭连接"""
        if self.ws:
            await self.ws.close()
            self.ws = None


# ========== Helper Functions ==========

def get_pages(port: int = 18800) -> List[Dict]:
    """获取所有页面"""
    try:
        with urllib.request.urlopen(f"http://localhost:{port}/json/list", timeout=5) as r:
            return json.loads(r.read())
    except urllib.error.URLError as e:
        raise CDPError(
            f"Cannot connect to CDP at port {port}.\n"
            f"Please start browser first:\n"
            f"  browser(action='start', profile='chrome')"
        )


def get_gemini_page(port: int = 18800) -> Optional[str]:
    """获取 Gemini 页面 ID"""
    pages = get_pages(port)
    # 优先精确匹配首页
    for page in pages:
        if page.get("url") == "https://gemini.google.com/app":
            return page["id"]
    # 其次匹配任何 Gemini 页面
    for page in pages:
        if "gemini.google.com" in page.get("url", ""):
            return page["id"]
    return None


def get_cdp_version(port: int = 18800) -> Dict:
    """获取 CDP 版本信息"""
    try:
        with urllib.request.urlopen(f"http://localhost:{port}/json/version", timeout=5) as r:
            return json.loads(r.read())
    except urllib.error.URLError:
        raise CDPError(f"CDP not available at port {port}")


def check_cdp_available(port: int = 18800) -> bool:
    """检查 CDP 是否可用"""
    try:
        get_cdp_version(port)
        return True
    except CDPError:
        return False


# ========== 测试 ==========

async def main():
    import sys
    sys.stdout.reconfigure(encoding='utf-8')
    
    port = 18800
    
    print("=== CDP Client Test ===")
    
    # 检查 CDP
    if not check_cdp_available(port):
        print(f"CDP not available at port {port}")
        print("Please start browser: browser(action='start', profile='chrome')")
        return
    
    version = get_cdp_version(port)
    print(f"Browser: {version.get('Browser', 'Unknown')}")
    
    # 获取 Gemini 页面
    page_id = get_gemini_page(port)
    if not page_id:
        print("No Gemini page found")
        print("Please open: browser(action='open', url='https://gemini.google.com/app')")
        return
    
    print(f"Gemini page: {page_id[:16]}...")
    
    # 连接并操作
    async with CDPClient(port) as client:
        await client.connect(page_id)
        await client.enable("Runtime", "Input")
        
        # 获取页面信息
        title = await client.eval_js("document.title")
        url = await client.eval_js("window.location.href")
        print(f"Title: {title}")
        print(f"URL: {url}")


if __name__ == "__main__":
    asyncio.run(main())