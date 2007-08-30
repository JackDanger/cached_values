class Leprechaun < ActiveRecord::Base
  has_cached_value :favorite_color_in_rot_13, :eval => Proc.new {|leprechaun| leprechaun.favorite_color.tr "A-Za-z", "N-ZA-Mn-za-m" }
  has_cached_value :favorite_color_turned_uppercase, :eval => "favorite_color.upcase"
  has_cached_value :id_of_first_leprechaun_with_same_favorite_color, :sql => 'select id from leprechauns where leprechauns.favorite_color = "#{favorite_color}" and leprechauns.id <> #{id} limit 1'
  has_cached_value :favorite_color_in_rot_13_without_cache, :eval => Proc.new {|leprechaun| leprechaun.favorite_color.tr "A-Za-z", "N-ZA-Mn-za-m" }, :cache => false
  has_cached_value :favorite_color_turned_uppercase_with_explicit_cache, :eval => "favorite_color.upcase", :cache => 'some_other_cache_field'
end
