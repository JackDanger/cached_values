require 'active_record'
require File.expand_path(File.dirname(__FILE__) + "/cached_values/cached_value")
require File.expand_path(File.dirname(__FILE__) + "/cached_values/caches_value")

module CachedValues # :nodoc:
  def self.perform_save?
    @perform_save
  end

  def self.without_saving_record
    @perform_save = false
    yield
    @perform_save = true
  end
end

ActiveRecord::Base.send :include, CachesValues
