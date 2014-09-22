require 'open-uri'
require_relative 'xpath_runner'
require_relative 'sanitizer'

module Scrapouille
  class Scraper

    def initialize(rules)
      @rules = rules
    end

    def scrap_each_from!(root, relative_uris)
      full_uris = relative_uris.map { |uri| "#{root}/#{uri}" }
      scrap_each!(full_uris)
    end

    def scrap_each!(uris)
      uris.map { |uri| scrap!(uri) }
    end

    def scrap!(uri)
      page = open(uri).read

      results = @rules.inject({}) do |acc, rule|
        result_hash = rule.run do |xpath|
          items = XpathRunner.new(xpath, page).get
          Sanitizer.clean!(items)
        end
        acc.merge!(result_hash)
      end

      results
    end

  end
end
