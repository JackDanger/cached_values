require 'active_record'
require File.expand_path(File.dirname(__FILE__) + "/cached_values/cached_value")
require File.expand_path(File.dirname(__FILE__) + "/cached_values/cached_values")
ActiveRecord::Base.send :include, CachedValues
