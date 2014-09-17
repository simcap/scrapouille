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

  def add_rule(property, xpath)
    @rules ||= []
    if block_given?
      @rules << [property, xpath, Proc.new]
    else
      @rules << [property, xpath]
    end
  end

  def run!
    web_page = open(@uri).read
    html = Nokogiri::HTML(web_page)
    @rules.inject({}) do |memo, rule|
      property, xpath, block = rule
      content = html.xpath(xpath).text.strip 
      content = block.call(content) if block
      memo[property.to_sym] = content 
      memo
    end
  end

end
