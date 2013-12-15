module Tantrum
  class ClientService
    @@clients = YAML.load_file(File.dirname(__FILE__) + "/../config/client_config.yml")["clients"]
    
    def self.client_exists?(client)
      @@clients.include?(client)
    end
    
    def self.get_config(client)
      @@clients[client]
    end
  end
end