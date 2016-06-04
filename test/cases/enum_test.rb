require 'test_helper'

class MysqlEnumTest < MysqlTestCase
  class EnumTest < ActiveRecord::Base
  end

  def test_enum_limit
    assert_equal 6, EnumTest.columns.first.limit
  end
end
