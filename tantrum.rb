require 'sinatra/base'

module Tantrum
  class Application < Sinatra::Base
    configure :production, :development do
      enable :logging
    end
  
    get '/' do
      erb :index
    end
  
    post '/upload' do
      StorageService.save(params['client'], params['file'][:tempfile].read, File.extname(params['file'][:filename]))
    end
  
    get '/assets/:client/*' do |client, path|
      content = StorageService.get(client, path)
      StorageCache.save(client, path, content)
      
      mime_type = MIME::Types.type_for(path)
      content_type mime_type.first.content_type
      content
    end
  end
end