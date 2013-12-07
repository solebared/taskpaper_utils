require "bundler/gem_tasks"

# Added by devtools
require 'devtools'
Devtools.init_rake_tasks

task('metrics:coverage').clear

namespace :metrics do
  desc 'Measure code coverage'
  task :coverage do
    begin
      original, ENV['COVERAGE'] = ENV['COVERAGE'], 'true'
      Rake::Task['spec:unit'].execute
    ensure
      ENV['COVERAGE'] = original
    end
  end
end
