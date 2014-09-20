require 'open-uri'
require 'nokogiri'

class Scrapouille

  def initialize(&block)
    @rules = []
    @collection_rules = []
    instance_eval(&block) if block_given?
  end

  def scrap_all(property, xpath_options)
    raise "Missing 'at:' option for '#{property}'" unless xpath_options[:at]
    xpath_string = xpath_options[:at]
    @collection_rules << [property, xpath_string]
  end

  def scrap(property, xpath_options)
    raise "Missing 'at:' option for '#{property}'" unless xpath_options[:at]
    xpath_string = xpath_options[:at]
    if block_given?
      @rules << [property, xpath_string, Proc.new]
    else
      @rules << [property, xpath_string]
    end
  end

  def scrap!(uri)
    web_page = open(uri).read
    html = Nokogiri::HTML(web_page)
    item_results = @rules.inject({}) do |result, rule|
      property, xpath, block = rule
      content = html.xpath(xpath).text.strip 
      content = block.call(content) if block
      result[property.to_sym] = content 
      result
    end
    collection_results = @collection_rules.inject({}) do |result, rule|
      property, xpath, block = rule
      content = html.xpath(xpath)
      if peek = content.first
        if Nokogiri::XML::Attr === peek
          result[property.to_sym] = content.map(&:value) 
        else
          result[property.to_sym] = content.map(&:text) 
        end
      end
      result
    end
    item_results.merge(collection_results)
  end

end
