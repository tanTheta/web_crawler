# web_crawler
Ruby web crawler to collect unique hrefs.
- Starts from a root url and filters all hrefs.
- Formats URLs using the uri lib.
- Exclusion list can be passed as an array if you wish to exclude any URL with certain patterns. For example, `sign_in?`.
- Traversed urls are stored in a set and are not visited more than once.
- Traversable urls are stored in a set.
- Invalid urls are stored in a set.
