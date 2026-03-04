#!/usr/bin/env python3
"""
Spider 爬虫示例
使用 Spider 框架进行多页面爬取
"""

from scrapling.spiders import Spider, Response


class ProductSpider(Spider):
    """产品爬虫示例"""

    name = "products"
    start_urls = ["https://example.com/products"]

    # 并发控制
    concurrency_limit = 5
    download_delay = 1.0  # 1 秒延迟

    async def parse(self, response: Response):
        """解析产品列表页"""

        # 提取所有产品
        products = response.css('.product-card')
        print(f"找到 {len(products)} 个产品")

        for product in products:
            yield {
                'title': product.css('.title::text').get(),
                'price': product.css('.price::text').get(),
                'rating': product.css('.rating::attr(data-value)').get(),
                'url': product.css('a::attr(href)').get()
            }

        # 处理分页
        next_page = response.css('.pagination .next::attr(href)').get()
        if next_page:
            print(f"下一页: {next_page}")
            yield response.follow(next_page, self.parse)


class BlogSpider(Spider):
    """博客爬虫示例"""

    name = "blog"
    start_urls = ["https://example.com/blog"]

    async def parse(self, response: Response):
        """解析博客列表"""

        # 提取文章链接
        articles = response.css('.blog-list a')
        print(f"找到 {len(articles)} 篇文章")

        for article in articles:
            # 获取链接
            url = article.css('::attr(href)').get()

            # 跟转到文章详情页
            yield response.follow(url, self.parse_article)

    async def parse_article(self, response: Response):
        """解析文章详情页"""

        yield {
            'url': response.url,
            'title': response.css('h1::text').get(),
            'author': response.css('.author::text').get(),
            'date': response.css('.date::text').get(),
            'content': ' '.join(response.css('.content p::text').getall()),
            'tags': response.css('.tags a::text').getall()
        }


if __name__ == '__main__':
    # 运行爬虫
    print("启动产品爬虫...")
    ProductSpider().start()

    # 或者运行博客爬虫
    # print("启动博客爬虫...")
    # BlogSpider().start()
