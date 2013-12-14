module Tantrum
  class ClientService
    
    def initialize
      @clients = YAML.load_file(File.dirname(__FILE__) + "/../config/client_config.yml")["clients"]
    end
    
    def client_exists?(client)
      @clients.include?(client)
    end
  end
end