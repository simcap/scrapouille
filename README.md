Declarative HTML scraper

# Usage

### Test

    rake

### Scrap

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

Use you scraper instance on an URI (as defined by `open-uri`: filepath, http, ...)

    ```ruby
    results = scraper.scrap!('http://tennis-player.com/richard-gasquet')
    results['fullname'] # => 'Richard Gasquest'
    ```

You can test your xpath expression with a local HTML filepath

    ```ruby
    scraper.scrap!(File.join('..', 'player.html'))
    ```

