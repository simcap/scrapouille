require 'open-uri'
require_relative 'xpath_runner'

module Scrapouille
  class Scraper

    def initialize(&block)
      @rules = {single: [], multiple: []} 
      instance_eval(&block) if block_given?
    end

    def scrap_all(property, xpath_options)
      block = Proc.new if block_given? 
      add_rule_to(:multiple, property, xpath_options, block)
    end

    def scrap(property, xpath_options)
      block = Proc.new if block_given? 
      add_rule_to(:single, property, xpath_options, block)
    end

    def scrap!(uri)
      page = open(uri).read

      item_results = @rules[:single].inject({}) do |acc, rule|
        property, xpath, block = rule

        result = XpathRunner.new(xpath, page).get_unique
        result.strip!
        result = block.call(result) if block

        acc[property.to_sym] = result 
        acc
      end

      collection_results = @rules[:multiple].inject({}) do |acc, rule|
        property, xpath, block = rule

        results = XpathRunner.new(xpath, page).get_all
        results = results.map do |r|
          block.call(r) 
        end if block

        acc[property.to_sym] = results
        acc
      end

      item_results.merge(collection_results)
    end

    private

    def add_rule_to(bucket, property, xpath_options, block = nil)
      raise "Missing 'at:' option for '#{property}'" unless xpath_options[:at]
      @rules[bucket] << ([property, xpath_options[:at], block].compact)
    end

  end
end
