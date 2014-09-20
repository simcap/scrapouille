module Scrapouille
  module Sanitizer

    HTML_NBSP_ENTITY = "\u00A0".freeze

    def self.clean!(items)
      items.map! do |i|
        next if i.nil?
        n = i.gsub(HTML_NBSP_ENTITY, ' ')
        n = n.squeeze(' ')
        n.strip
      end
    end

  end
end
