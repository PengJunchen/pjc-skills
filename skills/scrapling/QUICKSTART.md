# Scrapling 快速开始

## 安装依赖

```bash
pip install -r requirements.txt
```

如果需要 DynamicFetcher：
```bash
pip install scrapling[all]
```

## 1. 最简单的抓取

```python
from scrapling.fetchers import Fetcher

page = Fetcher.fetch('https://example.com')
title = page.css('title::text').get()
print(title)
```

## 2. 抓取多个元素

```python
page = Fetcher.fetch('https://example.com/products')

# 方法 1: 一次性获取所有
titles = page.css('.product-title::text').getall()

# 方法 2: 遍历处理
products = []
for product in page.css('.product'):
    products.append({
        'name': product.css('.title::text').get(),
        'price': product.css('.price::text').get()
    })
```

## 3. 绕过反爬虫

```python
from scrapling.fetchers import StealthyFetcher

StealthyFetcher.adaptive = True
page = StealthyFetcher.fetch(
    'https://example.com',
    headless=True,
    network_idle=True
)
```

## 4. 抓取 JavaScript 内容

```python
from scrapling.fetchers import DynamicFetcher

page = DynamicFetcher.fetch(
    'https://example.com',
    headless=True,
    js_enabled=True,
    wait_for_selector='.product'
)
```

## 5. Spider 爬虫

```python
from scrapling.spiders import Spider, Response

class MySpider(Spider):
    name = "demo"
    start_urls = ["https://example.com"]

    async def parse(self, response: Response):
        for item in response.css('.item'):
            yield {'title': item.css('::text').get()}

MySpider().start()
```

## CSS 选择器参考

| 选择器 | 说明 | 示例 |
|--------|------|------|
| `.class` | 类选择器 | `.product` |
| `#id` | ID 选择器 | `#header` |
| `tag` | 标签选择器 | `div`, `a` |
| `tag::text` | 文本内容 | `h1::text` |
| `tag::attr(attr)` | 属性值 | `a::attr(href)` |

## 常见问题

### Q: 如何处理动态加载的内容？
A: 使用 `DynamicFetcher` 并设置 `wait_for_selector`。

### Q: 网站返回 403 怎么办？
A: 使用 `StealthyFetcher` 或配置代理。

### Q: 如何设置代理？
A: 在 `fetch()` 方法中添加 `proxies=['http://proxy.com']` 参数。

### Q: 如何保存数据？
A: 使用 Python 的 `json.save()` 或写入 CSV 文件。

## 更多示例

查看 `examples/` 目录：
- `simple_scraping.py` - 静态页面抓取
- `stealthy_scraping.py` - 反爬虫绕过
- `dynamic_scraping.py` - 动态内容抓取
- `spider_example.py` - Spider 爬虫
- `data_extraction.py` - 数据提取技巧

## 文档

📖 [完整文档](https://scrapling.readthedocs.io)
