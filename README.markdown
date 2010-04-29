Cached Values
=

[http://github.com/JackDanger/cached_values/](http://github.com/JackDanger/cached_values/)

Cache the result of any Ruby expression or SQL into an ActiveRecord attribute. Expire and update automatically.

INSTALL:
===

* as gem: sudo gem install cached_values
* as plugin: ./script/plugin install git://github.com/JackDanger/cached_values.git

USAGE:
===

You can calculate values with a single line in any ActiveRecord model.  To actually save those values you'll need to create
an attribute in your schema.  By default the cached_value instance will look for an attribute with the same name as itself.
You can override this by specifying a :cache => :some_attribute option

A very simple case in which cached_values works just like the .count method on a has_many association:

    class Leprechaun < ActiveRecord::Base
      caches_value :total_gold_coins, :sql => 'select count(*) from gold_coins where leprechaun_id = #{id}'
    end
  
    Company.find(4).total_employees # => 45

A more sophisticated example:

    class Leprechaun < ActiveRecord::Base
      has_many :lucky_charms
      has_many :deceived_children, :through => :lucky_charms
      caches_value :total_children_remaining_to_be_deceived, :sql => '... very complicated sql here ...'
    end
  
    Leprechaun.find(14).total_children_remaining_to_be_deceived # => 6,692,243,122

The values can be of any type.  The plugin will attempt to cast SQL results to the type corresponding with their database cache
but calculations in Ruby are left alone.

You can also calculate the value in Ruby using a string to be eval'ed or a Proc.  Both are evaluated
in the context of the record instance.

    class Leprechaun < ActiveRecord::Base
      caches_value :total_gold, :eval => "some_archaic_and_silly_calculation(gold_coins)"
      caches_value :total_lucky_charms, :eval => Proc.new {|record| record.calculate_total_lucky_charms }
    end

The cache is customizable, you can specify which attribute should be used as a cache:
  
    caches_value :runic_formula, :sql => '...'          # uses 'runic_formula' column if it exists
    caches_value :standard_deviation_of_gold_over_time, # uses 'std' column if it exists
                 :sql => '...', :cache => 'std'
    caches_value :id, :sql => '...', :cache => false    # does NOT persist to db, just memoize in memory.  This avoids overwriting the attribute of the same name.

ActiveRecord callbacks can be used to reload (update cache and reload instance) at certain times:
  
    caches_value :standard_deviation, :sql => '...', :reload => [:before_save, :after_destroy]
    caches_value :runic_formula, :sql => '...', :reload => :after_create


Patches welcome, forks celebrated.

Copyright (c) 2007 Jack Danger Canty @ [http://jåck.com](http://jåck.com), released under the MIT license
