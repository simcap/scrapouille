require 'open-uri'
require 'nokogiri'

class Scrapouille

  def scrap!
    web_page = open('http://www.tennis.com/player/468/richard-gasquet/').read
    html = Nokogiri::HTML(web_page)
    fullname = html.xpath("//div[@class='player-name']/h1/child::text()").text
    {fullname: fullname.strip}
  end

end
