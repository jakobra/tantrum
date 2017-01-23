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
    
    post '/upload' do
      request.body.rewind
      payload = JSON.parse(request.body.read)
      check_client(payload['client'])
      
      content_key = StorageService.save(payload["client"], Base64.strict_decode64(payload["content"]), payload["filename"])
      content_type "application/json"
      {status: "OK", content_key: content_key}.to_json
    end
  
    get '/assets/:client/:key.:extension' do |client, key, extension|
      get_content(client, key, extension)
    end

    get '/assets/:client/:key/:filename.:extension' do |client, key, filename, extension|
      get_content(client, key, extension)
    end

    def get_content(client, key, extension)
      check_client(client)
      resource_key, template = key.split("$")
      begin
        e_tag, mod_at = StorageService.get_metadata(client, resource_key, template)
      rescue AWS::S3::Errors::NoSuchKey => e
        halt 404
      end
      
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
    
    delete '/assets/:client/:key.:extension' do |client, key, extension|
      check_client(client)
      begin
        StorageService.delete(client, key, extension)
      rescue AWS::S3::Errors::NoSuchKey => e
        halt 404
      end
      
      status 204
    end
    
    def check_client(client)
      raise "Invalid client" unless ClientService.client_exists?(client)
    end
  end
end