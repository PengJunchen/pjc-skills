#!/usr/bin/env python3
"""
数据提取和自适应解析示例
"""

from scrapling.fetchers import Fetcher
import json


def extract_product_data(page):
    """
    提取产品数据 - 使用多种选择器技巧
    """
    products = []

    # 方法 1: 使用 ::text 获取文本
    for product in page.css('.product'):
        title = product.css('.title::text').get()
        price = product.css('.price::text').get()

        if title and price:
            products.append({
                'title': title.strip(),
                'price': price.strip()
            })

    return products


def extract_with_attributes(page):
    """
    提取属性数据
    """
    data = []

    for item in page.css('.item'):
        # 提取单个属性
        url = item.css('a::attr(href)').get()

        # 提取多个属性
        attrs = {
            'id': item.css('::attr(data-id)').get(),
            'class': item.css('::attr(class)').get(),
            'category': item.css('::attr(data-category)').get(),
            'url': url
        }

        data.append(attrs)

    return data


def extract_nested_data(page):
    """
    提取嵌套数据
    """
    articles = []

    for article in page.css('article'):
        # 嵌套选择器
        articles.append({
            'title': article.css('h2::text').get(),
            'author': article.css('.meta .author::text').get(),
            'date': article.css('.meta .date::text').get(),
            'summary': article.css('.summary p::text').get(),
            'tags': article.css('.tags a::text').getall()
        })

    return articles


def adaptive_parsing_demo(url: str):
    """
    自适应解析演示
    """
    print(f"抓取并启用自适应: {url}")

    # 首次抓取 - auto_save 学习结构
    page1 = Fetcher.fetch(url)
    products_v1 = page1.css('.product', auto_save=True)
    print(f"首次找到 {len(products_v1)} 个产品")

    # 网站更新后 - adaptive=True 重新定位
    page2 = Fetcher.fetch(url)
    products_v2 = page2.css('.product', adaptive=True)
    print(f"更新后找到 {len(products_v2)} 个产品")

    return products_v2


def safe_extraction_demo(url: str):
    """
    安全提取演示 - 处理缺失数据
    """
    print(f"安全提取: {url}")

    page = Fetcher.fetch(url)

    items = []
    for element in page.css('.item'):
        # 安全提取 - 检查 None
        title = element.css('.title::text').get()
        price = element.css('.price::text').get()

        # 只添加有数据的条目
        if title:
            items.append({
                'title': title.strip(),
                'price': price.strip() if price else 'N/A',
                'available': 'yes' if element.css('.in-stock') else 'no'
            })

    return items


def extract_to_json(page, output_file: str):
    """
    提取数据并保存为 JSON
    """
    data = []

    for product in page.css('.product'):
        data.append({
            'id': product.css('::attr(data-id)').get(),
            'title': product.css('.title::text').get(),
            'price': product.css('.price::text').get(),
            'rating': product.css('.rating::attr(data-value)').get()
        })

    # 保存为 JSON
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"已保存 {len(data)} 条数据到 {output_file}")
    return data


if __name__ == '__main__':
    url = 'https://example.com'

    # 示例 1: 基本提取
    print("示例 1: 基本提取")
    page = Fetcher.fetch(url)
    products = extract_product_data(page)
    print(f"找到 {len(products)} 个产品")

    # 示例 2: 属性提取
    print("\n示例 2: 属性提取")
    attrs = extract_with_attributes(page)
    print(f"找到 {len(attrs)} 个项目")

    # 示例 3: 自适应解析
    print("\n示例 3: 自适应解析")
    adaptive = adaptive_parsing_demo(url)

    # 示例 4: 安全提取
    print("\n示例 4: 安全提取")
    safe_data = safe_extraction_demo(url)
    print(f"找到 {len(safe_data)} 个有效项目")

    # 示例 5: 保存 JSON
    print("\n示例 5: 保存 JSON")
    extract_to_json(page, 'output.json')
