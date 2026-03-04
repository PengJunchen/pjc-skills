# Scrapling Skill

基于 [Scrapling](https://github.com/D4Vinci/Scrapling) 的网页抓取技能。

## 简介

Scrapling 是一个自适应网页爬取框架，支持：

- **多种 Fetcher**：`Fetcher`、`AsyncFetcher`、`StealthyFetcher`、`DynamicFetcher`
- **爬虫框架**：类似 Scrapy 的 Spider API，支持并发、代理轮换
- **自适应解析**：当网站结构变化时自动重新定位元素
- **反爬虫绕过**：默认绕过 Cloudflare Turnstile 等防护

## 安装

```bash
pip install scrapling
```

完整功能：
```bash
pip install scrapling[all]
```

## 核心概念

### Fetcher 选择

| Fetcher | 用途 | 特点 |
|---------|------|------|
| `Fetcher` | 静态页面 | 基于 requests，简单快速 |
| `AsyncFetcher` | 异步请求 | 基于 aiohttp，高并发 |
| `StealthyFetcher` | 反爬虫保护 | 爬虫伪装，绕过 Cloudflare |
| `DynamicFetcher` | 动态内容 | Headless 浏览器，支持 JS |

### Spider 框架

用于大规模爬取：
- 并发控制
- 代理轮换
- 暂停/恢复
- 实时统计

## 快速示例

### 1. 简单抓取

```python
from scrapling.fetchers import Fetcher

page = Fetcher.fetch('https://example.com')
titles = page.css('h2::text').getall()
```

### 2. 反爬虫抓取

```python
from scrapling.fetchers import StealthyFetcher

StealthyFetcher.adaptive = True
page = StealthyFetcher.fetch(
    'https://example.com',
    headless=True,
    network_idle=True
)
products = page.css('.product', auto_save=True)
```

### 3. 动态内容

```python
from scrapling.fetchers import DynamicFetcher

page = DynamicFetcher.fetch(
    'https://example.com',
    headless=True,
    js_enabled=True,
    wait_for_selector='.product'
)
```

### 4. Spider 爬取

```python
from scrapling.spiders import Spider, Response

class ProductSpider(Spider):
    name = "products"
    start_urls = ["https://example.com/products"]

    async def parse(self, response: Response):
        for product in response.css('.product'):
            yield {
                "title": product.css('h2::text').get(),
                "price": product.css('.price::text').get()
            }

ProductSpider().start()
```

## 自适应解析

```python
# 首次抓取 - auto_save 保存结构
products = page.css('.product', auto_save=True)

# 网站更新后 - adaptive=True 重新定位
products = page.css('.product', adaptive=True)
```

## 使用场景

✅ 适合：
- 抓取网页数据（静态/动态）
- 批量爬取多页面
- 提取结构化数据
- 绕过反爬虫保护
- 处理 JavaScript 渲染的内容

❌ 不适合：
- 非网页数据源
- 需要 ML 分析的场景
- 实时性要求极高的场景

## 相关资源

- 📖 [官方文档](https://scrapling.readthedocs.io)
- 🕷️ [GitHub 仓库](https://github.com/D4Vinci/Scrapling)
- 💬 [Discord 社区](https://discord.gg/EMgGbDceNQ)

## 技能触发条件

当用户提到以下内容时，此技能会自动触发：
- "scrape", "crawl", "extract data from"
- "web scraping", "数据抓取", "爬虫"
- "parse HTML", "fetch web content"
- 具体网站 URL + 提取需求
