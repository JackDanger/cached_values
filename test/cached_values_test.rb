require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/test_helper")
require File.expand_path(File.dirname(__FILE__) + "/leprechaun")

class CachedValuesTest < Test::Unit::TestCase
  
  def setup
    @mc_nairn = Leprechaun.find(:first)
    @mc_nairn.favorite_color_in_rot_13.clear
    @mc_nairn.favorite_color_turned_uppercase.clear
    @mc_nairn.id_of_first_leprechaun_with_same_favorite_color.clear
    @mc_nairn.favorite_color_in_rot_13_without_cache.clear
    @mc_nairn.favorite_color_turned_uppercase_with_explicit_cache.clear
    @mc_nairn.favorite_color = 'blue'
    @mc_nairn.save!
  end
  
  def teardown
    setup
  end
  
  def test_proc_should_properly_calculate_value
    leprechaun = @mc_nairn
    assert_equal 'blue', leprechaun.favorite_color
    assert_equal 'oyhr', leprechaun.favorite_color.tr("A-Za-z", "N-ZA-Mn-za-m")
    assert_equal 'oyhr', leprechaun.favorite_color_in_rot_13
  end
  
  def test_string_should_properly_calculate_value
    leprechaun = @mc_nairn
    assert_equal 'blue', leprechaun.favorite_color
    assert_equal 'BLUE', leprechaun.favorite_color_turned_uppercase
    leprechaun.update_attribute(:favorite_color, 'gold')
    assert_equal 'BLUE', leprechaun.favorite_color_turned_uppercase
    assert_equal 'GOLD', leprechaun.favorite_color_turned_uppercase.reload
  end
  
  def test_sql_should_properly_calculate_value
    leprechaun = @mc_nairn
    assert_equal 3, leprechaun.id_of_first_leprechaun_with_same_favorite_color
    Leprechaun.find_by_name("O' Houhlihan").update_attribute(:favorite_color, 'blue')
    assert_equal 3, leprechaun.id_of_first_leprechaun_with_same_favorite_color
    assert_equal 2, leprechaun.id_of_first_leprechaun_with_same_favorite_color.reload
    
  end
  
  def test_should_cache_value
    leprechaun = @mc_nairn
    assert_equal 'blue', leprechaun.favorite_color
    assert_equal 'oyhr', leprechaun.favorite_color_in_rot_13
    leprechaun.update_attribute(:favorite_color, 'red')
    assert_equal 'erq', leprechaun.favorite_color.tr("A-Za-z", "N-ZA-Mn-za-m")
    assert_equal 'oyhr', leprechaun.favorite_color_in_rot_13
  end

  def test_cache_should_be_invalidated_on_clear
    leprechaun = @mc_nairn
    assert_equal 'blue', leprechaun.favorite_color
    assert_equal 'oyhr', leprechaun.favorite_color_in_rot_13
    leprechaun.favorite_color_in_rot_13.clear
    assert_nil leprechaun.send(:read_attribute, :favorite_color_in_rot_13)
  end
  
  def test_value_should_be_updated_after_its_cleared
    leprechaun = @mc_nairn
    assert_equal 'blue', leprechaun.favorite_color
    assert_equal 'oyhr', leprechaun.favorite_color_in_rot_13
    leprechaun.update_attribute(:favorite_color, 'red')
    assert_equal 'oyhr', leprechaun.favorite_color_in_rot_13
    leprechaun.favorite_color_in_rot_13.clear    
    assert_equal 'erq', leprechaun.favorite_color_in_rot_13
  end
  
  def test_should_not_cache_explicitly_noncaching_values
    leprechaun = @mc_nairn
    assert_equal 'blue', leprechaun.favorite_color
    assert_equal 'oyhr', leprechaun.favorite_color_in_rot_13_without_cache
    assert_nil leprechaun.send(:read_attribute, :favorite_color_in_rot_13_without_cache)
    leprechaun.update_attribute(:favorite_color, 'red')
    assert_equal 'erq', leprechaun.favorite_color.tr("A-Za-z", "N-ZA-Mn-za-m")
    assert_equal 'erq', leprechaun.favorite_color_in_rot_13_without_cache.reload
    assert_nil leprechaun.send(:read_attribute, :favorite_color_in_rot_13_without_cache)
  end
  
  def test_should_respect_explicit_cache_column
    leprechaun = @mc_nairn
    assert_equal 'BLUE', leprechaun.favorite_color_turned_uppercase_with_explicit_cache
    assert_equal 'BLUE', leprechaun.send(:read_attribute, :some_other_cache_field)
    leprechaun.update_attribute(:favorite_color, 'red')
    assert_equal 'BLUE', leprechaun.send(:read_attribute, :some_other_cache_field)
    assert_equal 'RED', leprechaun.favorite_color_turned_uppercase_with_explicit_cache.reload
  end
  
  def test_reload_callback_should_fire
    leprechaun = @mc_nairn
    value = leprechaun.reload_callback.to_s
    assert_equal value.to_i, leprechaun.reload_callback
    leprechaun.save!
    assert_not_equal value.to_i, leprechaun.reload_callback.reload
    value = leprechaun.reload_callback.to_s
    assert_equal value.to_i, leprechaun.reload_callback
    leprechaun.valid?
    assert_not_equal value.to_i, leprechaun.reload_callback
  end
  
  def test_clear_callback_should_fire
    leprechaun = @mc_nairn
    assert leprechaun.clear_callback
    assert leprechaun.instance_variable_get("@clear_callback")
    leprechaun.valid?
    assert_nil leprechaun.instance_variable_get("@clear_callback")
  end
end