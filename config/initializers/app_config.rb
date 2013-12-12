require 'yaml'

APP_CONFIG = YAML.load_file(File.dirname(__FILE__) + "/../app_config.yml")["tantrum"]