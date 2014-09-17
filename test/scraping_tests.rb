require 'minitest/autorun'
require 'minitest/pride'

require_relative '../lib/scrapouille' 

class ScrapingTest < MiniTest::Test

  def test_one_player_scrapping
    results = Scrapouille.new.scrap! 
    assert_equal({fullname: 'Richard Gasquet'}, results)
  end

end
