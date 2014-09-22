require 'open-uri'
require_relative 'xpath_runner'
require_relative 'sanitizer'

module Scrapouille
  class Scraper

    def initialize(scrap_unique, scrap_all)
      @scrap_unique_rules = scrap_unique
      @scrap_all_rules = scrap_all 
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

      results = @scrap_unique_rules.inject({}) do |acc, rule|
        property, items = run_rule(rule, page)
        acc[property] = items.first
        acc
      end

      @scrap_all_rules.inject(results) do |acc, rule|
        property, items = run_rule(rule, page)
        acc[property] = items
        acc
      end

      results
    end

    private

    def run_rule(rule, page)
      property, xpath, block = rule.property, rule.xpath_string, rule.block

      items = XpathRunner.new(xpath, page).get

      Sanitizer.clean!(items)

      items.map! do |i|
        block.call(i) 
      end if block

      [property, items]
    end

  end
end
