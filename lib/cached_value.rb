gem 'object_proxy'
require 'object_proxy'
  
module ActiveRecord
  class CachedValue < ObjectProxy

    def initialize(owner, reflection)
      @owner, @reflection = owner, reflection
    end
    
    def load(force_update = false)
      @target = find_target force_update
      if force_update || (has_cache? && find_target_from_cache.nil?)
        update_cache @target
      end
      self
    end

    def reload
      @owner.send(@reflection.name).load(true)
    end
    
    alias update reload
    
    def clear
      clear_cache
      @owner.instance_variable_set("@#{@reflection.name}", nil)
      self
    end

    def target
      @target
    end

    def find_target(skip_cache = false)
      target = find_target_from_cache unless skip_cache
      unless target
        target ||= @reflection.options[:sql] ? find_target_by_sql : find_target_by_eval
      end
      target
    end
    
    protected
      
      def find_target_from_cache
        @owner.send(:read_attribute, cache_column) if has_cache?
      end
      
      def find_target_by_sql
        sql = interpolate_and_sanitize_sql(@reflection.options[:sql])
        result = @owner.class.connection.select_value(sql)
        result = typecast_result(result)
        result
      end
    
      def find_target_by_eval
        if @reflection.options[:eval].is_a?(String)
          @owner.send :eval, @reflection.options[:eval]
        elsif @reflection.options[:eval].is_a?(Proc)
          @reflection.options[:eval].call(@owner)
        elsif @reflection.options[:eval].is_a?(Symbol)
          @owner.send @reflection.options[:eval]
        else
          raise ArgumentError.new("The :eval option on a cached_values must be a String or a Proc or a Symbol")
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

        @owner.send(:write_attribute, cache_column, value)

        return if @owner.new_record? || !CachedValues.perform_save?

        exist_conditions = value.nil? ?
                              [ "#{cache_column} IS NULL AND id = ?", @owner.id ] :
                              [ "(#{cache_column} = ? AND #{cache_column} IS NOT NULL) AND id = ?", value, @owner.id ]

        return if @owner.class.exists? exist_conditions

        @owner.class.update_all   [ "#{cache_column} = ?", value], ["id = ?", @owner.id ]
      end
      
      def typecast_result(result)
        if has_cache?
          typecast_sql_result_by_cache_column_type(result)
        else
          if result =~ /^\d+\.\d+$/
            result.to_f
          elsif result =~ /^\d+$/
            result.to_i
          else
            result
          end
        end
      end
      
      def typecast_sql_result_by_cache_column_type(result)
        type = @owner.column_for_attribute(cache_column).type
        case type
        when :integer
          result.to_i
        when :float
          result.to_f
        when :boolean
          [0,'0', 'NULL', 'nil', 'false', '', 'FALSE', 'False'].include?(result)
        else
          result
        end
      end
      
      def interpolate_and_sanitize_sql(sql, record = nil)
        sanitized = @owner.class.send(:sanitize_sql, sql, record)
        if sanitized =~ /\#\{.*\}/
          @owner.instance_eval("%@#{sanitized.gsub('@', '\@')}@", __FILE__, __LINE__)
        else
          sanitized
        end
      end
      
  end
end
