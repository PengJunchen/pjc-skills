---
name: scrapling
description: "Web scraping framework with adaptive parser, multiple fetchers, and spider framework. Use when user needs to scrape websites, crawl data, or fetch web content."
---

# Scrapling - Web Scraping Made Easy

## Overview

Scrapling is an adaptive web scraping framework that handles everything from a single request to a full-scale crawl. Choose the right fetcher for your needs:

- **Fetcher** - Simple HTTP requests (requests-based)
- **AsyncFetcher** - Async HTTP requests (aiohttp-based)
- **StealthyFetcher** - Bypass anti-bot systems (Cloudflare Turnstile, etc.)
- **DynamicFetcher** - Headless browser for dynamic content

## When to Use This Skill

Use Scrapling when user needs to:
- Scrape web pages (static or dynamic)
- Crawl multiple pages
- Extract structured data from websites
- Bypass anti-bot protections
- Handle pages with JavaScript-rendered content

## Quick Start

### Simple Page Scraping

```python
from scrapling.fetchers import Fetcher

page = Fetcher.fetch('https://example.com')
products = page.css('.product')  # CSS selector
titles = [p.css('h2::text').get() for p in products]
```

### Stealthy Scraping (Anti-Bot Bypass)

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

### Dynamic Content (Headless Browser)

```python
from scrapling.fetchers import DynamicFetcher

page = DynamicFetcher.fetch(
    'https://example.com',
    headless=True,
    js_enabled=True,
    wait_for_selector='.product'
)
```

## Spider Framework

For multi-page crawling, use Spider:

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

        # Follow pagination
        next_page = response.css('.next-page::attr(href)').get()
        if next_page:
            yield response.follow(next_page, self.parse)

ProductSpider().start()
```

## Adaptive Parsing

Scrapling's parser learns from website changes:

```python
# First time scrape - auto_save learns the structure
products = page.css('.product', auto_save=True)

# Later - adaptive=True relocates elements after site updates
products = page.css('.product', adaptive=True)
```

## Best Practices

1. **Choose the right fetcher**:
   - Static pages → Fetcher or AsyncFetcher
   - Anti-bot protected → StealthyFetcher
   - Dynamic content → DynamicFetcher

2. **Use auto_save for learning**:
   - Enable `auto_save=True` on first scrape
   - Later use `adaptive=True` to handle changes

3. **Rate limiting**:
   - Set `download_delay` in Spider to avoid blocking
   - Use proxy rotation for large-scale crawls

4. **Error handling**:
   - Check `page.status` for HTTP errors
   - Use try/except for missing elements

5. **Testing**:
   - Test selectors on small page first
   - Validate data structure before full crawl

## Common Operations

### Extract Text Content
```python
# Single element
title = page.css('h1::text').get()

# All elements
links = page.css('a::attr(href)').getall()

# Multiple elements
titles = [p.css('::text').get() for p in page.css('.title')]
```

### Extract Attributes
```python
# Get single attribute
product_url = product.css('::attr(href)').get()

# Get multiple attributes
for item in page.css('.item'):
    yield {
        'id': item.css('::attr(data-id)').get(),
        'class': item.css('::attr(class)').get()
    }
```

### Handle Missing Data
```python
price = product.css('.price::text').get()
if price:
    yield {'price': price.strip()}
```

## Configuration Examples

### Proxy Support
```python
from scrapling.fetchers import Fetcher

proxies = ['http://proxy1.com', 'http://proxy2.com']
page = Fetcher.fetch('https://example.com', proxies=proxies)
```

### Custom Headers
```python
page = Fetcher.fetch(
    'https://example.com',
    headers={'User-Agent': 'Custom Bot 1.0'}
)
```

### Spider With Limits
```python
class LimitedSpider(Spider):
    name = "limited"
    start_urls = ["https://example.com"]

    # Max concurrent requests
    concurrency_limit = 5

    # Delay between requests
    download_delay = 1.0

    # Max pages to crawl
    max_pages = 100
```

## Installation

```bash
pip install scrapling
```

For full-featured crawling:
```bash
pip install scrapling[all]
```

## Documentation

- 📖 [Official Docs](https://scrapling.readthedocs.io)
- 🕷️ [Selection Methods](https://scrapling.readthedocs.io/en/latest/parsing/selection/)
- 📡 [Fetchers](https://scrapling.readthedocs.io/en/latest/fetching/choosing/)
- 🕷️ [Spiders](https://scrapling.readthedocs.io/en/latest/spiders/architecture.html)
- 🔄 [Proxy Rotation](https://scrapling.readthedocs.io/en/latest/spiders/proxy-blocking.html)

## Skill Usage

This skill is automatically triggered when user mentions:
- "scrape", "crawl", "extract data from"
- "web scraping", "data extraction"
- "parse HTML", "fetch web content"
- Specific website URLs with extraction needs

Help user:
1. Choose appropriate fetcher (based on page type & protection)
2. Write CSS selectors for data extraction
3. Set up Spider for multi-page crawls
4. Handle anti-bot measures if needed
5. Configure proxy/headers if required
