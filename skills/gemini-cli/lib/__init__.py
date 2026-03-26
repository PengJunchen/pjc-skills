# gemini-cli lib
"""
Gemini CLI 工具库

提供:
- CDPClient: 轻量级 CDP 客户端
- GeminiClient: Gemini 操作客户端
"""

from .cdp_client import CDPClient, CDPError, get_gemini_page, get_pages, check_cdp_available
from .gemini_client import GeminiClient, ImageResult, ChatResult, generate_image, chat, get_status

__all__ = [
    'CDPClient',
    'CDPError',
    'get_gemini_page',
    'get_pages',
    'check_cdp_available',
    'GeminiClient',
    'ImageResult',
    'ChatResult',
    'generate_image',
    'chat',
    'get_status',
]