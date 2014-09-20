require_relative 'scrapouille/scraper'
require_relative 'scrapouille/sanitizer'
require_relative 'scrapouille/xpath_runner'

module Scrapouille

  def self.configure(&block)
    Scraper.new(&block)
  end

end
