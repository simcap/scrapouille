require 'nokogiri'

module Scrapouille
  class XpathRunner

    def initialize(xpath, html)
      @xpath = xpath 
      @html_content = Nokogiri::HTML(html)
    end

    attr_reader :xpath, :html_content
    private :xpath, :html_content

    def get
      result = html_content.xpath(xpath)

      if peek = result.first
        if Nokogiri::XML::Attr === peek
          result.map(&:value) 
        else
          result.map(&:text) 
        end
      else
        []
      end
    end

  end
end
