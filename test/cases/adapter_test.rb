require 'support/connection_helper'
require 'test_helper'

class User < ActiveRecord::Base; end

class MysqlAdapterTest < MyTestCase
  def setup
    ConnectionHelper.connection_config
    @dummy_model = User
  end

  def test_class_available
    puts @dummy_model.connection.name
    assert_equal "Mysql", dummy_model.connection.adapter_name
  end
end
