require 'helper'

class TestScraping < MiniTest::Unit::TestCase

  def test_scrap_text
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

  def test_scrap_attribute_value
    scraper = Scrapouille.new do 
      scrap 'djokovic_picture_src', at: "//img[contains(@src, 'djokovicz')]/@src"
    end

    results = scraper.scrap!(File.join(__dir__, 'fixtures', 'tennis-players-listing.html'))

    assert_equal(
      { djokovic_picture_src: 'http://cdn.tennis.com/uploads/img/2014/06/12/djokoviczz/regular.jpg' }, 
      results
    )
  end

  def test_scrap_all_attributes_value
    scraper = Scrapouille.new do 
      scrap_all 'players_hrefs', at: "//table[contains(@class, 'ranking-table')]//a[child::img]/@href"
    end

    results = scraper.scrap!(File.join(__dir__, 'fixtures', 'tennis-players-listing.html'))

    assert results[:players_hrefs]
    assert results[:players_hrefs].all? {|p| p.start_with? '/player/'}
    assert_equal 119, results[:players_hrefs].count
    assert_equal '/player/532/novak-djokovic/', results[:players_hrefs].first
  end

  def test_scrap_all_text
    scraper = Scrapouille.new do 
      scrap_all 'players_names', at: "//table[contains(@class, 'ranking-table')]//a[not(child::img)]/text()"
    end

    results = scraper.scrap!(File.join(__dir__, 'fixtures', 'tennis-players-listing.html'))

    assert results[:players_names]
    assert_equal 119, results[:players_names].count
    assert_equal 'Novak Djokovic', results[:players_names].first
  end

  def test_both_scrap_and_scrap_all
    scraper = Scrapouille.new do 
      scrap 'djokovic_picture_src', at: "//img[contains(@src, 'djokovicz')]/@src"
      scrap_all 'players_hrefs', at: "//table[contains(@class, 'ranking-table')]//a[child::img]/@href"
    end

    results = scraper.scrap!(File.join(__dir__, 'fixtures', 'tennis-players-listing.html'))

    assert results[:players_hrefs]
    assert_equal 119, results[:players_hrefs].count

    assert_equal(
      'http://cdn.tennis.com/uploads/img/2014/06/12/djokoviczz/regular.jpg',
      results[:djokovic_picture_src] 
    )
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
