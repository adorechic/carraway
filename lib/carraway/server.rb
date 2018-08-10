require 'sinatra'

module Carraway
  class Server < Sinatra::Base
    set :views, File.expand_path('../views', __FILE__)

    get '/' do
      erb :top
    end

    get '/new' do
      erb :new
    end

    post '/' do
      Post.create(
        title: params[:title],
        path: params[:path],
        body: params[:body],
        category_key: params[:category]
      )
      'Created!'
    end
  end
end
