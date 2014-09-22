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
      ensure_valid_definition(property, xpath_options)
      block = Proc.new if block_given? 
      add_rule(:collect_all, property, xpath_options, block)
    end

    def scrap(property, xpath_options)
      ensure_valid_definition(property, xpath_options)
      block = Proc.new if block_given? 
      add_rule(:collect_unique, property, xpath_options, block)
    end

    def scrap_each!(*uris)
      if uris.length == 1 
        full_uris = uris.first
      elsif uris.length == 2
        root, relative_uris = *uris
        full_uris = relative_uris.map do |uri| "#{root}/#{uri}" end
      else
        raise ArgumentError, "Expecting 1 or 2 arguments when calling #{__callee__}"
      end
      full_uris.map do |uri|
        scrap!(uri)
      end
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

    def add_rule(bucket, property, xpath_options, block = nil)
      @rules[bucket] << ([property, xpath_options[:at], block].compact)
    end

    def ensure_valid_definition(property, xpath_options)
      raise ArgumentError, 'Expecting Hash as second argument for scraping rules' unless Hash === xpath_options
      raise "Missing 'at:' option for '#{property}'" unless xpath_options[:at]
    end

  end
end
