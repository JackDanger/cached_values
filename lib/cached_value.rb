
module ActiveRecord
  class CachedValue
    attr_reader :reflection
    instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send|reflection$)/ }

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
      
      def load_target
        return nil unless defined?(@loaded)
        @target = find_target unless loaded?
        @loaded = true
        @target
      end

      def find_target
        target = find_target_from_cache
        unless target
          target ||= @reflection.options[:sql] ? find_target_by_sql : find_target_by_eval
          update_cache(target)
        end
        target
      end
      
      def find_target_from_cache
        @owner.send(:read_attribute, cache_column) if has_cache?
      end
      
      def find_target_by_sql
        @owner.class.count_by_sql(sanitize_sql(interpolate_sql(@reflection.options[:sql])))
      end
    
      def find_target_by_eval
        if @reflection.options[:eval].is_a?(String)
          eval(@reflection.options[:eval], @owner.send(:binding))
        elsif @reflection.options[:eval].is_a?(Proc)
          @reflection.options[:eval].call(@owner)
        else
          raise ArgumentError.new("The :eval option on a cached_values must be either a String or a Proc")
        end
      end
      
      def cache_column
        @reflection.options[:cache]
      end

      def has_cache?
        @reflection.options[:cache] && @owner.attribute_names.include?(@reflection.options[:cache].to_s)
      end
      
      def clear_cache
        update_cache(nil)
      end
      
      def update_cache(value)
        return unless has_cache?
        unless @owner.new_record?
          @owner.class.update_all(["#{cache_column} = ?", value], ["id = ?", @owner.id])
        end
        @owner.send(:write_attribute, cache_column, value)
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
