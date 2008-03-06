require 'active_record'
require File.expand_path(File.dirname(__FILE__) + "/cached_values/cached_value")
require File.expand_path(File.dirname(__FILE__) + "/cached_values/caches_value")

module CachedValues # :nodoc:
  VERSION = '1.0.0'
end

ActiveRecord::Base.send :include, CachesValues
