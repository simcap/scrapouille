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

    def get
      result = html_content.xpath(xpath)

      if unique_result
        result = result.first if result.respond_to? :first

        if Nokogiri::XML::Attr === result
          return result.value
        else
          return result.text
        end
      else
        if peek = result.first
          if Nokogiri::XML::Attr === peek
            return result.map(&:value) 
          else
            return result.map(&:text) 
          end
        end
      end
    end

  end
end
