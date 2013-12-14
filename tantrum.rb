require 'sinatra/base'

module Tantrum
  class Application < Sinatra::Base
    configure :production, :development do
      enable :logging
    end
    
    def initialize(app = nil)
      super(app)
      @image_service = ImageService.new
    end
  
    get '/' do
      erb :index
    end
  
    post '/upload' do
      StorageService.save(params['client'], params['file'][:tempfile].read, File.extname(params['file'][:filename]))
    end
  
    get '/assets/:client/*$*.*' do |client, resource_key, template, extension|
      content, c_type = StorageService.get(client, resource_key + "." + extension)
      
      manipulated = @image_service.manipulate(client, content, template)
      StorageCache.save(client, "#{resource_key}$#{template}.#{extension}", manipulated)
      
      content_type c_type
      manipulated
    end
  end
end