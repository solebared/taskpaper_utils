# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'taskpaper_tools/version'

Gem::Specification.new do |gem|
  gem.name          = "taskpaper_tools"
  gem.version       = TaskpaperTools::VERSION
  gem.authors       = ["lasitha ranatunga"]
  gem.email         = ["exbinary@gmail.com"]
  gem.summary       = %q{Parse and work with TaskPaper formatted documents.}
  gem.license       = 'LGPL-3.0'
  gem.homepage      = "https://github.com/exbinary/taskpaper_tools"
  gem.description   = %{
    Simple library for working with TaskPaper formatted documents.
    Parse a TaskPaper document, work with the resulting set of
    model objects and reserialize.
  }

  gem.add_development_dependency 'rspec',     '~> 2.14'
  gem.add_development_dependency 'rubocop',   '~> 0.15'
  gem.add_development_dependency 'simplecov', '~> 0.08'

  # todo: depending on git here may not be portable
  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib"]
end
