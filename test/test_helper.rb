# Include this file in your test by copying the following line to your test:
#   require File.expand_path(File.dirname(__FILE__) + "/test_helper")

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require "cached_values"
require File.expand_path(File.dirname(__FILE__) + "/leprechaun")

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

load(File.dirname(__FILE__) + "/schema.rb") if File.exist?(File.dirname(__FILE__) + "/schema.rb")

class Test::Unit::TestCase #:nodoc:
  
  # def create_fixtures(*table_names)
  #   if block_given?
  #     Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
  #   else
  #     Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
  #   end
  # end

  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true
  
  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
end