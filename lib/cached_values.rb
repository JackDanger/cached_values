module HasCachedValueExtension # :nodoc:
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    # USAGE:
    #  
    # a very simple case in which has_cached_value works just like the .count method on a has_many association:
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
    
    def caches_value(association_id, options = {})
      reflection = create_has_cached_value_reflection(association_id, options)

      configure_dependency_for_has_cached_value(reflection)

      reflection.options[:counter_cache] = reflection.options.delete(:cache) if reflection.options[:cache]
      reflection.options[:counter_cache] ||= reflection.name unless false == reflection.options[:counter_cache]

      association_accessor_method(reflection, ActiveRecord::Associations::HasCachedValueAssociation)
    end

    private
    
      def configure_dependency_for_has_cached_value(reflection)
        if reflection.options[:counter_cache] && reflection.options[:cache]
          raise ArgumentError, ":cache is an alias for :counter_cache, don't use both options for has_cached_value in #{self.name}"
        end
      
        if !reflection.options[:sql] && !reflection.options[:eval]
          raise ArgumentError, "You must specify either the :eval or :sql options for has_cached_value in #{self.name}"
        end
      
        if reflection.options[:sql] && reflection.options[:eval]
          raise ArgumentError, ":eval and :sql are mutually exclusive options.  You may specify one or the other for has_cached_value in #{self.name}"
        end
      end
    
      def create_has_cached_value_reflection(association_id, options)
        options.assert_valid_keys(:sql, :eval, :cache, :counter_cache)
        
        reflection = ActiveRecord::Reflection::AssociationReflection.new(:has_cached_value, association_id, options, self)
        write_inheritable_hash :reflections, association_id => reflection
        reflection
      end

      def association_accessor_method(reflection, association_proxy_class)
        define_method(reflection.name) do |*params|
          force_reload = params.first unless params.empty?
          association = instance_variable_get("@#{reflection.name}")
          
          if association.nil? || force_reload
            association = association_proxy_class.new(self, reflection)
            instance_variable_set("@#{reflection.name}", association)
            force_reload ? association.reload : association.load
          end
          association.target.nil? ? nil : association
        end
      end
  end
end

module ActiveRecord
  module Associations
    class HasCachedValueAssociation
      attr_reader :reflection
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$)/ }

      def initialize(owner, reflection)
        @owner, @reflection = owner, reflection
        reset
      end
      
      def reset
        @target = nil
        @loaded = false
      end

      def load
        reset
        load_target
      end

      def reload
        reset
        clear_cache
        load_target
      end
      
      def clear
        clear_cache
        @owner.instance_variable_set("@#{@reflection.name}", nil)
      end

      def loaded?
        @loaded
      end
      
      def loaded
        @loaded = true
      end
      
      def target
        @target
      end

      protected
      
        def find_target_by_eval
          if @reflection.options[:eval].is_a?(String)
            eval(@reflection.options[:eval], @owner.send(:binding))
          elsif @reflection.options[:eval].is_a?(Proc)
            @reflection.options[:eval].call(@owner)
          else
            raise ArgumentError.new("The :eval option on a has_cached_value must be either a String or a Proc")
          end
        end
        
        def find_target_by_sql
          @owner.class.count_by_sql(sanitize_sql(interpolate_sql(@reflection.options[:sql])))
        end
        
        def find_target_from_cache
          @owner.send(:read_attribute, @reflection.counter_cache_column) if has_cached_counter?
        end

        def find_target
          target = find_target_from_cache
          unless target
            target ||= @reflection.options[:sql] ? find_target_by_sql : find_target_by_eval
            update_cache(target)
          end
          target
        end
        
        def update_cache(value)
          return unless has_cached_counter?
          unless @owner.new_record?
            @owner.class.update_all(["#{@reflection.counter_cache_column} = ?", value], ["id = ?", @owner.id])
          end
          @owner.send(:write_attribute, @reflection.counter_cache_column, value)
        end
        
        def clear_cache
          update_cache(nil)
        end
        
        def load_target
          return nil unless defined?(@loaded)
          @target = find_target unless loaded?
          @loaded = true
          @target
        end

        def has_cached_counter?
          @reflection.options[:counter_cache] && @owner.attribute_names.include?(@reflection.options[:counter_cache].to_s)
        end
        
        def interpolate_sql(sql, record = nil)
          @owner.send(:interpolate_sql, sql, record)
        end

        def sanitize_sql(sql)
          @owner.class.send(:sanitize_sql, sql)
        end
        
        def method_missing(method, *args, &block)
          if load_target        
            @target.send(method, *args, &block)
          end
        end
    end
  end
end
