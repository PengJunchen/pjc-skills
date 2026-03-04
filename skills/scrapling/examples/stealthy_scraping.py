#!/usr/bin/env python3
"""
反爬虫抓取示例
使用 StealthyFetcher 绕过 Cloudflare Turnstile 等防护
"""

from scrapling.fetchers import StealthyFetcher


def scrape_protected_site(url: str):
    """
    抓取有反爬虫保护的网站
    """
    print(f"抓取受保护网站: {url}")

    # 启用自适应模式
    StealthyFetcher.adaptive = True

    # 使用 headless 模式和 network_idle
    page = StealthyFetcher.fetch(
        url,
        headless=True,      # 无头浏览器
        network_idle=True,   # 等待网络空闲
        timeout=30           # 30 秒超时
    )

    if page.status != 200:
        print(f"失败: HTTP {page.status}")
        return None

    # 提取内容
    title = page.css('title::text').get()
    print(f"标题: {title}")

    # 使用 auto_save 保存结构（首次）
    articles = page.css('article', auto_save=True)
    print(f"找到 {len(articles)} 篇文章")

    # 提取数据
    data = []
    for article in articles:
        data.append({
            'title': article.css('h2::text').get(),
            'link': article.css('a::attr(href)').get(),
            'summary': article.css('p::text').get()
        })

    return data


if __name__ == '__main__':
    # 示例 URL（替换为实际需要抓取的网站）
    url = 'https://example.com'
    result = scrape_protected_site(url)

    if result:
        print("\n抓取结果:")
        for item in result[:5]:  # 只显示前 5 条
            print(f"- {item['title']}")
        print(f"\n总共 {len(result)} 条数据")
