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

  class ScrapFirstRule < ScrapingRule

    def process
      results = yield xpath_string  
      result = results.first
      result = block.call(result) if block
      [property, result]
    end

  end

  class ScrapAllRule < ScrapingRule

    def process
      results = yield xpath_string  
      results.map! {|i| block.call(i)} if block
      [property, results]
    end

  end
end
