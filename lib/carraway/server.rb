require 'sinatra'
require 'json'

module Carraway
  class Server < Sinatra::Base
    set :views, File.expand_path('../views', __FILE__)
    set :method_override, true

    get '/' do
      @categories = Category.all
      @category_posts = Post.all.group_by {|post| post.category.key }
      erb :top
    end

    get '/api/posts' do
      posts = Post.all.map(&:to_h)
      { data: { posts: posts } }.to_json
    end

    get '/new' do
      erb :new
    end

    get %r{/edit([\w\./]+)} do |path|
      @post = Post.find(path)
      # FIXME handle not found
      erb :edit
    end

    post '/' do
      Post.create(
        title: params[:title],
        path: params[:path],
        body: params[:body],
        category_key: params[:category]
      )
      # FIXME redirect with message
      'Created!'
    end

    patch '/update' do
      @post = Post.find(params[:path])
      # FIXME handle not found
      @post.assign(
        title: params[:title],
        body: params[:body]
      )
      # FIXME validation
      @post.save
      # FIXME redirect with message
      'Updated'
    end

    delete '/destroy' do
      @post = Post.find(params[:path]) # FIXME handle not found
      @post.destroy
      # FIXME redirect with message
      'Deleted'
    end
  end
end
