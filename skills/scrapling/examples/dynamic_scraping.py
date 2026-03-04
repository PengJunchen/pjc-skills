#!/usr/bin/env python3
"""
动态内容抓取示例
使用 DynamicFetcher 处理 JavaScript 渲染的内容
"""

from scrapling.fetchers import DynamicFetcher


def scrape_dynamic_page(url: str):
    """
    抓取需要 JavaScript 渲染的页面
    """
    print(f"抓取动态页面: {url}")

    page = DynamicFetcher.fetch(
        url,
        # Headless 配置
        headless=True,

        # 启用 JavaScript
        js_enabled=True,

        # 等待特定选择器出现
        wait_for_selector='.product-item',

        # 等待网络空闲（所有请求完成）
        network_idle=True,

        # 自定义等待时间（秒）
        page_load_timeout=30,
        wait_time=2,  # 额外等待 2 秒

        # 视口大小
        viewport={'width': 1920, 'height': 1080}
    )

    if page.status != 200:
        print(f"失败: HTTP {page.status}")
        return None

    # 提取动态生成的内容
    products = page.css('.product-item')
    print(f"找到 {len(products)} 个产品")

    data = []
    for product in products:
        data.append({
            'name': product.css('.name::text').get(),
            'price': product.css('.price::text').get(),
            'image': product.css('img::attr(src)').get()
        })

    return data


def scrape_infinite_scroll(url: str, scroll_count: int = 5):
    """
    抓取无限滚动页面
    """
    print(f"抓取无限滚动页面: {url}")

    # 使用 JavaScript 执行滚动
    js_script = f"""
        async () => {{
            let count = 0;
            while (count < {scroll_count}) {{
                window.scrollTo(0, document.body.scrollHeight);
                await new Promise(resolve => setTimeout(resolve, 1000));
                count++;
            }}
        }}
    """

    page = DynamicFetcher.fetch(
        url,
        headless=True,
        js_enabled=True,
        execute_js=js_script,  # 执行自定义 JavaScript
        network_idle=True
    )

    if page.status != 200:
        return None

    # 提取所有加载的内容
    items = page.css('.item')
    print(f"找到 {len(items)} 个项目")

    return [{'title': i.css('.title::text').get()} for i in items]


if __name__ == '__main__':
    # 示例 1: 简单动态页面
    url = 'https://example.com/products'
    result = scrape_dynamic_page(url)

    if result:
        print("\n结果:")
        for item in result[:3]:
            print(f"- {item['name']}: {item['price']}")

    # 示例 2: 无限滚动
    # scroll_url = 'https://example.com/feed'
    # scroll_result = scrape_infinite_scroll(scroll_url, scroll_count=5)
    # print(f"\n滚动后找到 {len(scroll_result)} 个项目")
