# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'taskpaper_tools/version'

Gem::Specification.new do |gem|
  gem.name          = "taskpaper_tools"
  gem.version       = TaskpaperTools::VERSION
  gem.authors       = ["lasitha ranatunga"]
  gem.email         = ["exbinary@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.add_development_dependency 'rspec', '~> 2.14.0'
  gem.add_development_dependency 'simplecov', '~> 0.8.0'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
