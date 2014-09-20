require 'open-uri'
require_relative 'xpath_runner'

module Scrapouille
  class Scraper

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

      item_results = @rules[:single].inject({}) do |result, rule|
        property, xpath, block = rule

        content = XpathRunner.new(xpath, page).get_unique
        content.strip!
        content = block.call(content) if block

        result[property.to_sym] = content 
        result
      end

      collection_results = @rules[:multiple].inject({}) do |result, rule|
        property, xpath, block = rule

        content = XpathRunner.new(xpath, page, false).get_all

        result[property.to_sym] = content
        result
      end

      item_results.merge(collection_results)
    end

  end
end
