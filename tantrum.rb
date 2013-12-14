require 'sinatra/base'
require "base64"

module Tantrum
  class Application < Sinatra::Base
    configure :production, :development do
      enable :logging
    end
    
    def initialize(app = nil)
      super(app)
      @image_service = ImageService.new
      @client_service = ClientService.new
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
      
      cool = StorageService.save(payload["client"], Base64.strict_decode64(payload["content"]), payload["filename"])
      logger.info cool
    end
  
    get '/assets/:client/:key.:extension' do |client, key, extension|
      check_client(client)
      resource_key = key.split("$")[0]
      template = key.split("$")[1]
      logger.info "resource_key => #{resource_key}"
      logger.info "template => #{template}"
      logger.info "extension => #{extension}"
      
      content, c_type = StorageService.get(client, resource_key + "." + extension)
      
      content = @image_service.manipulate(client, content, template) unless template == nil || template.empty?
      StorageCache.save(client, "#{key}.#{extension}", content)
      
      content_type c_type
      content
    end
    
    def check_client(client)
      raise "Invalid client" unless @client_service.client_exists?(client)
    end
  end
end