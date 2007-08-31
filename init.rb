require 'cached_value'
require 'cached_values'
ActiveRecord::Base.send :include, CachedValues
