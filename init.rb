require 'cached_values'
ActiveRecord::Base.send :include, HasCachedValueExtension
