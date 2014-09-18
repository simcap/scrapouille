# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "scrapouille"
  spec.version       = "0.0.2"
  spec.authors       = ["simcap"]
  spec.summary       = %q{Simpe XPath driven declarative HTML scraper}
  spec.description   = %q{Simpe XPath driven declarative HTML scraper}
  spec.homepage      = "https://github.com/simcap/scrapouille"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
