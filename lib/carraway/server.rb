require 'sinatra'

module Carraway
  class Server < Sinatra::Base
    set :views, File.expand_path('../views', __FILE__)

    get '/' do
      erb :top
    end
  end
end
