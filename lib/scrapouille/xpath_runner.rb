require 'nokogiri'

module Scrapouille
  class XpathRunner

    def initialize(xpath, html, unique_result = true)
      @xpath = xpath 
      @html_content = Nokogiri::HTML(html)
      @unique_result = unique_result
    end

    attr_reader :xpath, :html_content, :unique_result
    private :xpath, :html_content, :unique_result

    def get_unique
      result = html_content.xpath(xpath)

      result = result.first if result.respond_to? :first

      if Nokogiri::XML::Attr === result
        result.value
      else
        result.text
      end
    end

    def get_all
      result = html_content.xpath(xpath)

      if peek = result.first
        if Nokogiri::XML::Attr === peek
          result.map(&:value) 
        else
          result.map(&:text) 
        end
      end
    end

  end
end
