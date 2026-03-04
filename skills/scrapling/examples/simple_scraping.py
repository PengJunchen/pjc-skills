#!/usr/bin/env python3
"""
简单网页抓取示例
"""

from scrapling.fetchers import Fetcher


def scrape_simple_page(url: str):
    """
    抓取简单静态页面
    """
    print(f"抓取: {url}")
    page = Fetcher.fetch(url)

    # 检查状态码
    if page.status != 200:
        print(f"失败: HTTP {page.status}")
        return None

    # 提取标题
    title = page.css('title::text').get()
    print(f"标题: {title}")

    # 提取所有链接
    links = page.css('a::attr(href)').getall()
    print(f"找到 {len(links)} 个链接")

    # 提取所有图片
    images = page.css('img::attr(src)').getall()
    print(f"找到 {len(images)} 张图片")

    return {
        'title': title,
        'links_count': len(links),
        'images_count': len(images)
    }


if __name__ == '__main__':
    # 示例
    url = 'https://example.com'
    result = scrape_simple_page(url)

    if result:
        print("\n结果:")
        print(result)
