require 'sinatra/base'
require "base64"

module Tantrum
  class Application < Sinatra::Base
    configure :production, :development do
      enable :logging
    end
  
    get '/' do
      erb :index
    end
  
    post '/save' do
      check_client(params['client'])
      StorageService.save(params['client'], params['content'][:tempfile].read, params['content'][:filename])
    end
    
    post '/upload' do
      request.body.rewind
      payload = JSON.parse(request.body.read)
      check_client(payload['client'])
      
      content_key = StorageService.save(payload["client"], Base64.strict_decode64(payload["content"]), payload["filename"])
      content_type "application/json"
      {status: "OK", content_key: content_key}.to_json
    end
  
    get '/assets/:client/:key.:extension' do |client, key, extension|
      check_client(client)
      resource_key, template = key.split("$")
      e_tag, mod_at = StorageService.get_metadata(client, resource_key, template)
      
      config = ClientService.get_config(client)
      cache_control :public, :must_revalidate, :max_age => config["cache_max_age"]
      etag e_tag
      
      content, c_type = StorageService.get(client, resource_key, extension)
      
      content = ImageService.manipulate(client, content, template) unless template == nil
      StorageCache.save(client, "#{key}.#{extension}", content)
      
      last_modified mod_at
      content_type c_type
      content
    end
    
    def check_client(client)
      raise "Invalid client" unless ClientService.client_exists?(client)
    end
  end
end