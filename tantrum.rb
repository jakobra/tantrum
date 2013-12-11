require 'sinatra/base'

class Tantrum < Sinatra::Base
  get '/' do
    'Hello world!'
  end
end