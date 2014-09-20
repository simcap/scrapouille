require 'open-uri'
require_relative 'xpath_runner'

module Scrapouille
  class Scraper

    def initialize(&block)
      @rules = {collect_unique: [], collect_all: []} 
      instance_eval(&block) if block_given?
    end

    def scrap_all(property, xpath_options)
      block = Proc.new if block_given? 
      add_rule(:collect_all, property, xpath_options, block)
    end

    def scrap(property, xpath_options)
      block = Proc.new if block_given? 
      add_rule(:collect_unique, property, xpath_options, block)
    end

    def scrap!(uri)
      page = open(uri).read

      results = @rules[:collect_unique].inject({}) do |acc, rule|
        property, xpath, block = rule

        item = XpathRunner.new(xpath, page).get_unique
        sanitize!(item)

        item.map! do |i|
          block.call(i) 
        end if block

        acc[property.to_sym] = item.first 
        acc
      end

      @rules[:collect_all].inject(results) do |acc, rule|
        property, xpath, block = rule

        items = XpathRunner.new(xpath, page).get_all
        sanitize!(items)

        items.map! do |i|
          block.call(i) 
        end if block

        acc[property.to_sym] = items
        acc
      end

      results
    end

    private

    def sanitize!(items)
      items.map!(&:strip)
    end

    def add_rule(bucket, property, xpath_options, block = nil)
      raise "Missing 'at:' option for '#{property}'" unless xpath_options[:at]
      @rules[bucket] << ([property, xpath_options[:at], block].compact)
    end

  end
end
