# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cached_values}
  s.version = "1.9.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jack Danger Canty"]
  s.date = %q{2011-06-15}
  s.description = %q{Speedup your ActiveRecord by storing and updating the results of SQL or Ruby expressions into record attributes}
  s.email = %q{rubygems@6brand.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown"
  ]
  s.files = [
    "Gemfile",
    "LICENSE",
    "MIT-LICENSE",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "cached_values.gemspec",
    "init.rb",
    "install.rb",
    "lib/cached_value.rb",
    "lib/cached_values.rb",
    "tasks/cached_values_tasks.rake",
    "test/cached_values_test.rb",
    "test/database.yml",
    "test/leprechaun.rb",
    "test/schema.rb",
    "test/test_helper.rb",
    "uninstall.rb"
  ]
  s.homepage = %q{http://github.com/JackDanger/cached_values}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{Memoize and persist calculations into ActiveRecord attributes}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<object_proxy>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_runtime_dependency(%q<object_proxy>, [">= 0"])
      s.add_development_dependency(%q<active_record>, [">= 0"])
    else
      s.add_dependency(%q<object_proxy>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<object_proxy>, [">= 0"])
      s.add_dependency(%q<active_record>, [">= 0"])
    end
  else
    s.add_dependency(%q<object_proxy>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<object_proxy>, [">= 0"])
    s.add_dependency(%q<active_record>, [">= 0"])
  end
end

