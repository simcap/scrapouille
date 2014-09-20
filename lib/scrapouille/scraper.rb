require 'open-uri'
require_relative 'xpath_runner'
require_relative 'sanitizer'

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
        property, items = process_rule(rule, page)
        acc[property] = items.first
        acc
      end

      @rules[:collect_all].inject(results) do |acc, rule|
        property, items = process_rule(rule, page)
        acc[property] = items
        acc
      end

      results
    end

    private

    def process_rule(rule, page)
      property, xpath, block = rule

      items = XpathRunner.new(xpath, page).get

      Sanitizer.clean!(items)

      items.map! do |i|
        block.call(i) 
      end if block

      [property, items]
    end

    def sanitize!(items)
      items.map!(&:strip)
    end

    def add_rule(bucket, property, xpath_options, block = nil)
      raise "Missing 'at:' option for '#{property}'" unless xpath_options[:at]
      @rules[bucket] << ([property, xpath_options[:at], block].compact)
    end

  end
end
