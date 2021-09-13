# web_crawler
Ruby web crawler to collect unique hrefs.
- Starts from a root url and filters all hrefs. root url is the starting point from where you wish to start the crawler.
- Formats URLs using the uri lib.
- Exclusion list can be passed as an array if you wish to exclude any URL with certain patterns. For example, `sign_in?`.
- Traversed urls are stored in a set and are not visited more than once.
- Traversable urls are stored in a set.
- Invalid urls are stored in a set.

# Usage
- Crawler with Nokoriri. exclusion list can be passed as an optional parameter.{:exclusion_list => <Array of your exclusion list>}
```
DomainCrawler.new(root_url).inspect
```
- Crawler with Selenium Webdriver (This also works for JS pages)
  1. Create a browser object using Watir. 
  ```
  browser = Watir::Browser.new
  ```
  2. Alternately you can pass the browser object that is used in your test/spec file.
  Crawl and capture URLs
  ```
  DomainCrawler.new(root_url, {:is_js => true, :browser => @browser}).inspect
  ```

