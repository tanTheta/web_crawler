require 'nokogiri'
require 'rest-client'
require 'set'

class DomainCrawler
  include GlobalLogger
  attr_accessor :root_url, :exclusion_list, :invalid_urls
  attr_reader :traversed_urls, :traversable_urls

  # @param[String] root url : starting point of the crawler.
  # @param[Array] list of URL patterns that need to be excluded.
  def initialize(root_url, opts)
    @root_url = root_url
    @traversed_urls = Set.new
    @traversable_urls = Set.new
    @invalid_urls = []
    @traversable_urls << root_url
    @exclusion_list = opts[:exclusion_list] || []
    @browser = opts[:browser] || nil
    @is_js = opts[:is_js] || false
  end

  # validates and inspects the root URL.
  # Fetches href associated with a URL and added them to a set of traversable URLs.
  # Stores already traversed URLs in a set so they are not revisited.
  # @return[Array] Traversed URLs.
  def inspect
    until traversable_urls.empty?
      begin
        current_url = traversable_urls.first
        traversed_urls.add(current_url)
        hrefs = get_hrefs(current_url)
        hrefs.each do |href|
          examine_url(href) unless href.to_s.empty?
        end
      rescue StandardError => e
        g_debug(e.to_s)
      end
      traversable_urls.delete(traversable_urls.first)
    end

    raise StandardError.new('No URLs found during traversal. The domain name might be invalid.') if traversed_urls.empty?

    traversed_urls
  end

  private

  # Check if a url is traversable.
  # For a url to be traversable, it must start with or have the root url
  # For a url to be traversable, it must not already be part of traversed ot traversable urls.
  # For a url to be traversable, it must not match any pattern that is part of the exclusion_list
  # @return [Boolean]
  def url_traversable?(url)
    excluded = false
    url_format_check = url.start_with?(root_url) || url.include?(root_url.split('www.')[1])
    traversable = url_format_check &&
                  !traversed_urls.include?(url) &&
                  !traversable_urls.include?(url)
    excluded = (exclusion_list.any? { |s| url.include? s }) if exclusion_list.length.positive?
    traversable && !excluded
  end

  # Filter hrefs from a URL based on xpath
  # Makes a GET call on the URL. Added the URL to the invalid_urls list if response code is not 200.
  # @param(String) : URL
  # @param[String] : Selector to be used for filtering.
  # @return[Array] : Collection of hrefs
  def filter_href_by_xpath(url, selector)
    doc = Nokogiri::HTML(RestClient.get(url))
    doc.xpath(selector).map { |anchor| anchor['href'] }
  rescue StandardError => e
    invalid_urls << url
    g_debug("#{url} might be an invalid URL. #{e}")
  end

  # Filters href from a JS page.
  # Helps cature the elements that are loaded dynamically and are not available when the page loads first.
  def filter_js_hrefs(url, browser, selector)
    browser.get(url)
    browser.find_elements(:tag_name, selector).map {|link| link.href}
  rescue StandardError => e
    invalid_urls << url
    g_debug("#{url} might be an invalid URL. #{e}")
  end

  def get_hrefs(url)
    if @is_js
      raise 'Please pass a browser object' if @browser.nil?
      return filter_js_hrefs(url, @browser, "a")
    else
      return filter_href_by_xpath(url, '//a')
    end
  end

  # Examines the url adds it the traversable urls if all checks pass.
  # @return [Array] Traversable URLs
  def examine_url(url)
    url = URI.join(root_url, url).to_s
    traversable_urls << url if url_traversable?(url)
  end
end
