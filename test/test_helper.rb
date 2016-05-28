$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'activerecord/mysql/adapter'
require 'my_test_case'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


