require 'open-uri'
require 'nokogiri'

class Scrapouille

  def self.configure
    scraper = new
    yield scraper
    scraper
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

  def scrap!
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
