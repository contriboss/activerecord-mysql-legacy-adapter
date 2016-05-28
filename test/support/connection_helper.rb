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
end
