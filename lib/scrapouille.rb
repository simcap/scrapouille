require 'open-uri'
require 'nokogiri'

class Scrapouille

  def initialize(&block)
    @rules = {single: [], multiple: []} 
    instance_eval(&block) if block_given?
  end

  def scrap_all(property, xpath_options)
    raise "Missing 'at:' option for '#{property}'" unless xpath_options[:at]
    xpath_string = xpath_options[:at]
    @rules[:multiple] << [property, xpath_string]
  end

  def scrap(property, xpath_options)
    raise "Missing 'at:' option for '#{property}'" unless xpath_options[:at]
    xpath_string = xpath_options[:at]
    if block_given?
      @rules[:single] << [property, xpath_string, Proc.new]
    else
      @rules[:single] << [property, xpath_string]
    end
  end

  def scrap!(uri)
    page = open(uri).read
    html = Nokogiri::HTML(page)
    item_results = @rules[:single].inject({}) do |result, rule|
      property, xpath, block = rule

      content = html.xpath(xpath)
      content = content.first if content.respond_to? :first

      if Nokogiri::XML::Attr === content
        content = content.value
      else
        content = content.text.strip
      end
      content = block.call(content) if block
      result[property.to_sym] = content 
      result
    end

    collection_results = @rules[:multiple].inject({}) do |result, rule|
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
