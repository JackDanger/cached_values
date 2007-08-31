class Leprechaun < ActiveRecord::Base
  caches_value :favorite_color_in_rot_13, :eval => Proc.new {|leprechaun| leprechaun.favorite_color.tr "A-Za-z", "N-ZA-Mn-za-m" }
  caches_value :favorite_color_turned_uppercase, :eval => "favorite_color.upcase"
  caches_value :id_of_first_leprechaun_with_same_favorite_color, :sql => 'select id from leprechauns where leprechauns.favorite_color = "#{favorite_color}" and leprechauns.id <> #{id} limit 1'
  caches_value :favorite_color_in_rot_13_without_cache, :eval => Proc.new {|leprechaun| leprechaun.favorite_color.tr "A-Za-z", "N-ZA-Mn-za-m" }, :cache => false
  caches_value :favorite_color_turned_uppercase_with_explicit_cache, :eval => "favorite_color.upcase", :cache => 'some_other_cache_field'
  caches_value :reload_callback, :eval => "rand(1000)", :reload => [:before_save, :after_validation]
  caches_value :clear_callback, :eval => "rand(1000)", :clear => :before_validation
  caches_value :float_cast, :sql => "select 82343.222"
  caches_value :integer_cast, :sql => "select 19"
  caches_value :string_cast, :sql => 'select "Top \'o the mornin\' to ya"'
end
