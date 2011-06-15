require 'active_record'
require File.expand_path(File.dirname(__FILE__) + "/cached_value")

module CachedValues # :nodoc:
  def self.perform_save?
    @perform_save ||= true
  end

  def self.without_saving_record
    @perform_save = false
    yield
    @perform_save = true
  end
  
  def self.run?
    @enabled = true if @enabled.nil?
    @enabled
  end

  def self.disable!
    @enabled = false
  end

  def self.enable!
    @enabled = true
  end

  # USAGE:
  #  
  # a very simple case in which cached_values works just like the .count method on a has_many association:
  #   
  #   class Company < ActiveRecord::Base
  #     caches_value :total_employees, :sql => 'select count(*) from employees where company_id = #{id}'
  #   end
  #  
  # a more sophisticated example:
  #  
  #   class User < ActiveRecord::Base
  #     has_many :trinkets
  #     has_many :sales, :through => :trinkets
  #     caches_value :remaining_trinket_sales_allotted, :sql => '... very complicated sql here ...'
  #   end
  #  
  #   user = User.find(:first)
  #   user.remaining_trinket_sales_allotted # => 70
  #   Trinket.delete_all # <= any operation that would affect our value
  #   user.remaining_trinket_sales_allotted # => 70
  #   user.remaining_trinket_sales_allotted.reload # => 113
  #  
  # You can also calculate the value in Ruby.  This can be done by a string to be eval'ed or a Proc.  Both are evaluated
  # in the context of the record instance.
  #  
  #   class User < ActiveRecord::Base
  #     caches_value :expensive_calculation, :eval => "some_big_expensize_calculation(self.id)"
  #     caches_value :other_expensive_process, :eval => Proc.new {|record| record.other_expensize_process }
  #   end
  #
    
  def caches_value(name, options = {})
    reflection = create_cached_value_reflection(name, options)

    configure_dependency_for_cached_value(reflection)

    reflection.options[:cache] ||= reflection.name unless false == options[:cache]

    cached_value_accessor_method(reflection, ActiveRecord::CachedValue)
    cached_value_callback_methods(reflection)
  end

  private
  
    def configure_dependency_for_cached_value(reflection)
    
      if !reflection.options[:sql] && !reflection.options[:eval]
        raise ArgumentError, "You must specify either the :eval or :sql options for caches_value in #{self.name}"
      end
    
      if reflection.options[:sql] && reflection.options[:eval]
        raise ArgumentError, ":eval and :sql are mutually exclusive options.  You may specify one or the other for caches_value in #{self.name}"
      end
    end
  
    def create_cached_value_reflection(name, options)
      options.assert_valid_keys(:sql, :eval, :cache, :clear, :load, :reload)
      ActiveRecord::Reflection::MacroReflection.new(:cached_value, name, options, self)
    end

    def cached_value_accessor_method(reflection, association_proxy_class)
      define_method(reflection.name) do
        association = instance_variable_get("@#{reflection.name}")
        
        if association.nil?
          association = association_proxy_class.new(self, reflection)
          instance_variable_set("@#{reflection.name}", association)
          association.load
        end
        association.target.nil? ? nil : association
      end
    end
    
    def cached_value_callback_methods(reflection)
      if events = reflection.options[:reload]
        events = Array(events).map(&:to_sym)
        ActiveRecord::Callbacks::CALLBACKS.map(&:to_sym).each do |callback|
          if events.include?(callback)
            # before_save do |record|
            send callback do |record|
              if CachedValues.run?
                if %{before_save before_create before_destroy}.include?(callback.to_s)
                  CachedValues.without_saving_record do
                    record.send(reflection.name).reload
                  end
                else
                  record.send(reflection.name).reload
                end
              end
            end
          end
        end
      end
    end
end


ActiveRecord::Base.extend CachedValues