require_relative 'scrapouille/scraper'
require_relative 'scrapouille/sanitizer'
require_relative 'scrapouille/rules'
require_relative 'scrapouille/xpath_runner'

module Scrapouille

  class Config
  
    attr_reader :rules

    def initialize(&block)
      @rules = []
      instance_eval(&block) 
    end

    def scrap(property, xpath_options)
      block = Proc.new if block_given? 
      @rules << ScrapFirstRule.new(property, xpath_options, block)
    end

    def scrap_all(property, xpath_options)
      block = Proc.new if block_given? 
      @rules << ScrapAllRule.new(property, xpath_options, block)
    end

  end

  def self.configure(&block)
    config = Config.new(&block)
    Scraper.new(config.rules)
  end

end
