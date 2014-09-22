require_relative 'scrapouille/scraper'
require_relative 'scrapouille/sanitizer'
require_relative 'scrapouille/xpath_runner'

module Scrapouille

  class ScrapingRule 

    attr_reader :property, :xpath_string, :block

    def initialize(property, xpath_options, block = nil)
      raise ArgumentError, 'Expecting Hash as second argument' unless Hash === xpath_options
      raise "Missing 'at:' option for '#{property}'" unless xpath_options[:at]

      @property = property
      @xpath_string = xpath_options.fetch(:at)
      @block = block
    end
  end

  class Config
  
    attr_reader :scrap_all_rules, :scrap_rules

    def initialize(&block)
      @scrap_rules, @scrap_all_rules = [], []
      instance_eval(&block) 
    end

    def scrap(property, xpath_options)
      block = Proc.new if block_given? 
      @scrap_rules << ScrapingRule.new(property, xpath_options, block)
    end

    def scrap_all(property, xpath_options)
      block = Proc.new if block_given? 
      @scrap_all_rules << ScrapingRule.new(property, xpath_options, block)
    end

  end

  def self.configure(&block)
    config = Config.new(&block)
    Scraper.new(config.scrap_rules, config.scrap_all_rules)
  end

end
