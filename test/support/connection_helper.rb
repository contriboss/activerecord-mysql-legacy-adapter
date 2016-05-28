module ConnectionHelper
  class << self
    def connection_config
      ActiveRecord::Base.establish_connection config['test']
    end


    def config
      test_root = File.expand_path('../../', __FILE__)
      config_file = test_root + '/config.yml'

      YAML.load_file(config_file) if File.exist? config_file
    end
  end

  def run_without_connection
    original_connection = ActiveRecord::Base.remove_connection
    yield original_connection
  ensure
    ActiveRecord::Base.establish_connection(original_connection)
  end

  # Used to drop all cache query plans in tests.
  def reset_connection
    original_connection = ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection(original_connection)
  end
end
