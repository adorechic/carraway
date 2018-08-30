require 'sinatra'
require 'json'
require 'rack/flash'

module Carraway
  class Server < Sinatra::Base
    set :views, File.expand_path('../views', __FILE__)
    set :method_override, true
    enable :sessions
    use Rack::Flash

    get '/' do
      redirect '/carraway'
    end

    get '/carraway' do
      @categories = Category.all
      @category_posts = Post.all.group_by {|post| post.category.key }
      erb :top
    end

    get '/carraway/api/posts' do
      posts = Post.all.map(&:to_h)
      { data: { posts: posts } }.to_json
    end

    get '/carraway/new' do
      erb :new
    end

    get %r{/carraway/edit([\w\./]+)} do |path|
      @post = Post.find(path)
      # FIXME handle not found
      erb :edit
    end

    get %r{/carraway/preview([\w\./]+)} do |path|
      @post = Post.find(path)
      # FIXME handle not found

      # Refresh GatsbyJS
      uri = URI.parse("http://localhost:8000/__refresh")
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path)
      res = http.request(req) # FIXME Handle errors

      redirect "http://localhost:8000#{@post.path}"
    end

    post '/carraway' do
      @post = Post.create(
        title: params[:title],
        path: params[:path],
        body: params[:body],
        category_key: params[:category]
      )
      flash[:message] = 'Created'
      redirect "/carraway/edit#{@post.path}"
    end

    patch '/carraway/update' do
      @post = Post.find(params[:path])
      # FIXME handle not found
      @post.assign(
        title: params[:title],
        body: params[:body]
      )
      # FIXME validation
      @post.save
      flash[:message] = 'Updated'
      redirect "/carraway/edit#{@post.path}"
    end

    delete '/carraway/destroy' do
      @post = Post.find(params[:path]) # FIXME handle not found
      @post.destroy
      flash[:message] = "Deleted #{@post.path}"
      redirect "/carraway"
    end
  end
end
