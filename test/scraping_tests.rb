require 'minitest/autorun'
require 'minitest/pride'

require_relative '../lib/scrapouille' 

class ScrapingTest < MiniTest::Test

  def test_one_player_scrapping
    results = Scrapouille.scrap! do |scraper|
      scraper.uri File.join(__dir__, 'fixtures', 'tennis-player.html')
      scraper.add_rule fullname: "//div[@class='player-name']/h1/child::text()"
      scraper.add_rule image_url: "//div[@id='basic']//img/attribute::src"
    end
    assert_equal({
      fullname: 'Richard Gasquet',
      image_url: 'http://cdn.tennis.com/uploads/img/2014/06/12/gasquet/regular.jpg'
      }, 
      results)
  end

end
