# Scrapouille

Scrapouille is a declarative XPath driven HTML scraper with an interactive mode as a bonus

Why XPath ? XPath is powerful enough to get any data on a HTML document (see http://www.w3schools.com/xpath/xpath_axes.asp)

Scrapouille run XPath queries using the **nokogiri** gem

### Install

    gem install 'scrapouille'

### Test

    rake

# Usage

### Interactive mode

From the command line you can interact with a remote web page as if it was local

    $ scrapouille http://tennis.com/player.html        # launch scrapouille on the command line with a provided URI
    > //div[@class='player-name']/h1/child::text()     # You will get a prompt. Enter a xpath query
    Richard Gasquest                                   # Get the result string

**Behind the scene - during the session - the remote web page is stored in a `Tempfile` for fast xpath interaction**

You can also directly interact with a local file

    $ scrapouille /Users/simon/web/player.html         # launch scrapouille on the command line with a provided filepath
    > //div[@class='player-name']/h1/child::text()     # enter your xpath query
    Richard Gasquest                                   # Get the result String

### Scraping programatically

Define a scraper

```ruby
scraper = Scrapouille.new do
  scrap 'fullname', at: "//div[@class='player-name']/h1/child::text()"
  scrap 'image_url', at: "//div[@id='basic']//img/attribute::src"
  scrap 'rank', at: "//div[@class='position']/text()" do |c|
    Integer(c.sub('#', ''))
  end
end
```

Use the scraper instance on an URI (as defined by `open-uri`: filepath, http, ...)

```ruby
results = scraper.scrap!('http://tennis-player.com/richard-gasquet')
results['fullname'] # => 'Richard Gasquest'
```

You can also run your scraper using a local HTML filepath for testing purposes

```ruby
scraper.scrap!(File.join('..', 'player.html'))
```

