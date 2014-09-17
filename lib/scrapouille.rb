require 'open-uri'
require 'nokogiri'

class Scrapouille

  def self.scrap!
    scraper = new 
    yield scraper
    scraper.run!
  end

  def uri(uri)
    @uri = uri
  end

  def add_rule(rule)
    (@rules ||= []) << rule
  end

  def run!
    web_page = open(@uri).read
    html = Nokogiri::HTML(web_page)
    @rules.inject({}) do |memo, rule|
      key, value = rule.first
      memo[key] = html.xpath(value).text.strip 
      memo
    end
  end

end
