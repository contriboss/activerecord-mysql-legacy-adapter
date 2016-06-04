$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'active_support/logger'
require 'activerecord/mysql/adapter'
require 'support/connection_helper'
require 'mysql_test_case'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module ARTest
  class << self
    def connect
      ActiveRecord::Base.logger = ActiveSupport::Logger.new("debug.log", 0, 100 * 1024 * 1024)
      ActiveRecord::Base.establish_connection ConnectionHelper.config['test']
      # ARUnit2Model.establish_connection :arunit2
    end
  end
end

def load_schema
  schema_file = File.expand_path('../schema.rb', __FILE__)

  if File.exist?(schema_file)
    load schema_file
  end
ensure
  puts "#{schema_file} is missing"
end

# Show backtraces for deprecated behavior for quicker cleanup.
ActiveSupport::Deprecation.debug = true

I18n.enforce_available_locales = false

ARTest.connect

# Quote "type" if it's a reserved word for the current connection.
QUOTED_TYPE = ActiveRecord::Base.connection.quote_column_name('type')

# FIXME: Remove this when the deprecation cycle on TZ aware types by default ends.
ActiveRecord::Base.time_zone_aware_types << :time

load_schema

