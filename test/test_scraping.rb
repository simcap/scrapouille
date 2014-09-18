require 'helper'

class TestScraping < MiniTest::Unit::TestCase

  def test_one_player_scrapping
    scraper = Scrapouille.new do 
      scrap 'fullname', at: "//div[@class='player-name']/h1/child::text()"
      scrap 'image_url', at: "//div[@id='basic']//img/attribute::src"
      scrap 'rank', at: "//div[@class='position']/text()" do |c|
        Integer(c.sub('#', '')) 
      end
    end

    results = scraper.scrap!(File.join(__dir__, 'fixtures', 'tennis-player.html'))

    assert_equal({
      fullname: 'Richard Gasquet',
      image_url: 'http://cdn.tennis.com/uploads/img/2014/06/12/gasquet/regular.jpg',
      rank: 21
      }, 
      results)
  end

  def test_raise_when_no_at_options
    error = assert_raises(RuntimeError) do
      scraper = Scrapouille.new do 
        scrap 'fullname', {}
      end
    end
    assert_match /fullname/, error.message 
  end

end
