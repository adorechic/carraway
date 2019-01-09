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

  describe 'GET /carraway/api/posts' do
    let!(:post) do
      Carraway::Post.create(
        title: 'Post title',
        category_key: 'test_category',
        published: Time.now.to_i - 1,
        body: <<~BODY
        # Header
        body
        BODY
      )
    end

    it 'returns published posts' do
      get '/carraway/api/posts'
      expect(last_response).to be_ok

      json = JSON.parse(last_response.body)

      expect(json['data']['posts'].size).to eq(1)
      post_response = json['data']['posts'].first
      expect(post_response['title']).to eq(post.title)
      expect(post_response['body']).to eq(post.body)
    end

    context 'if post is not published' do
      before do
        post.published = nil
        post.save
      end

      it 'does not return posts' do
        get '/carraway/api/posts'
        expect(last_response).to be_ok

        json = JSON.parse(last_response.body)

        expect(json['data']['posts'].size).to eq(0)
      end
    end

    context 'if html view option is given' do
      it 'returns published posts' do
        get '/carraway/api/posts?view=html'
        expect(last_response).to be_ok

        json = JSON.parse(last_response.body)

        expect(json['data']['posts'].size).to eq(1)
        post_response = json['data']['posts'].first
        expect(post_response['title']).to eq(post.title)
        expect(post_response['body']).to eq(<<~BODY)
        <h1>Header</h1>

        <p>body</p>
        BODY
      end
    end
  end
end
