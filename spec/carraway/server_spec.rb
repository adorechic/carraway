require 'spec_helper'

RSpec.describe Carraway::Server, type: :request do
  before do
    Carraway::Config.load('spec/test.yml')
    Carraway::Post.setup
  end

  after do
    Carraway::Post.drop
  end

  describe 'GET /' do
    it do
      get '/'
      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to be_end_with('/carraway/')
    end
  end

  describe 'GET /carraway/' do
    let!(:post) do
      Carraway::Post.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )
    end

    it do
      get '/carraway/'
      expect(last_response).to be_ok
      expect(last_response.body).to include(%{<a href="/carraway/edit/#{post.uid}">#{post.title}</a>})
    end
  end
end
