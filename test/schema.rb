
require File.expand_path(File.dirname(__FILE__) + "/leprechaun")

ActiveRecord::Schema.define(:version => 1) do
  
  create_table :leprechauns do |t|
    t.column :name,                                             :string
    t.column :favorite_color,                                   :string
    t.column :favorite_color_in_rot_13,                         :string
    t.column :favorite_color_in_rot_13_without_cache,           :string
    t.column :favorite_color_turned_uppercase,                  :string
    t.column :id_of_first_leprechaun_with_same_favorite_color,  :integer
    t.column :some_other_cache_field,                           :string
    t.column :reload_callback,                                  :float
    t.column :clear_callback,                                   :float
  end
  
  Leprechaun.create!(:name => 'Mc Nairn', :favorite_color => 'blue')
  Leprechaun.create!(:name => "O' Houhlihan", :favorite_color => 'ochre')
  Leprechaun.create!(:name => "Danger Cáinte", :favorite_color => 'blue')
  
end
