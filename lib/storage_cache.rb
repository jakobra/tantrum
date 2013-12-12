require 'fileutils'

module Tantrum
  class StorageCache
    def self.save(client, path, content)
      local_path = File.dirname(__FILE__) + "/../public/assets/#{client}/#{path}"
      dir = File.dirname(local_path)
  
      unless File.directory?(dir)
        FileUtils.mkdir_p(dir)
      end
      
      open(local_path, 'wb') do |file|
        file << content
      end
    end
  end
end