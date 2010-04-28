begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cached_values"
    gem.summary = %Q{Memoize and persist calculations into ActiveRecord attributes}
    gem.description = %Q{Speedup your ActiveRecord by storing and updating the results of SQL or Ruby expressions into record attributes}
    gem.email = "gitcommit@6brand.com"
    gem.homepage = "http://github.com/JackDanger/cached_values"
    gem.authors = ["Jack Danger Canty"]
    gem.add_development_dependency "active_record", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end



task :default => :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << '.'
  test.pattern = 'test/*_test.rb'
  test.verbose = true
end
