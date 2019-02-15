require 'spec_helper'

RSpec.describe Carraway::Server, type: :request do
  before do
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

    context 'with label' do
      before do
        post.labels = %w(poem)
        post.save
      end

      it 'returns published posts' do
        get '/carraway/api/posts?view=html'
        expect(last_response).to be_ok

        json = JSON.parse(last_response.body)

        expect(json['data']['posts'].size).to eq(1)
        post_response = json['data']['posts'].first
        expect(post_response['labels']).to eq(%w(poem))
      end
    end
  end

  describe 'GET /carraway/new' do
    let(:file) do
      Carraway::File.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end

    before do
      Carraway::FileRepository.new.save(file)
    end

    it do
      get '/carraway/new'
      expect(last_response).to be_ok
      expect(last_response.body).to include(file.path)
    end
  end

  describe 'GET /carraway/edit/:id' do
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

    let(:file) do
      Carraway::File.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end

    before do
      Carraway::FileRepository.new.save(file)
    end

    it do
      get "/carraway/edit/#{post.uid}"
      expect(last_response).to be_ok
      expect(last_response.body).to include(post.title)
      expect(last_response.body).to include(file.path)
    end

  end

  describe 'GET /carraway/preview/:id' do
    let!(:post) do
      Carraway::Post.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )
    end

    before do
      stub_request(
        :post,
        [Carraway::Config.gatsby_endpoint, '/__refresh'].join
      )
    end

    it do
      get "/carraway/preview/#{post.uid}"

      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to be_end_with(post.path)
    end
  end

  describe 'POST /carraway/' do
    let(:params) do
      {
        title: 'Post title',
        body: 'Article Body',
        category: 'test_category'
      }
    end

    it do
      post "/carraway/", params

      expect(last_response).to be_redirect

      expect(Carraway::Post.all.size).to eq(1)
      post = Carraway::Post.all.first
      expect(post.title).to eq(params[:title])
      expect(post.labels).to eq(nil)
      expect(last_response.header["Location"]).to be_end_with(post.uid)
    end

    context 'with valid label' do
      before do
        params[:labels] = %w(poem)
      end

      it do
        post "/carraway/", params

        expect(last_response).to be_redirect

        expect(Carraway::Post.all.size).to eq(1)
        post = Carraway::Post.all.first
        expect(post.labels).to eq(%w(poem))
      end
    end
  end

  describe 'PATCH /carraway/update' do
    let!(:post) do
      Carraway::Post.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )
    end

    let(:params) do
      {
        uid: post.uid,
        title: 'New title',
        body: 'New body'
      }
    end

    it do
      patch '/carraway/update', params

      expect(last_response).to be_redirect

      saved_post = Carraway::Post.find(post.uid)
      expect(saved_post.title).to eq(params[:title])
      expect(last_response.header["Location"]).to be_end_with(post.uid)

    end
  end

  describe 'PATCH /carraway/publish' do
    let!(:post) do
      Carraway::Post.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )
    end

    let(:params) do
      {
        uid: post.uid
      }
    end

    it do
      patch '/carraway/publish', params

      expect(last_response).to be_redirect

      saved_post = Carraway::Post.find(post.uid)
      expect(saved_post.published).to_not eq(nil)
      expect(last_response.header["Location"]).to be_end_with(post.uid)
    end

    context 'given published time' do
      let(:published_at) { Time.new(2019, 1, 2, 12) }

      before do
        params[:published] = published_at.to_s
      end

      it do
        patch '/carraway/publish', params

        expect(last_response).to be_redirect

        saved_post = Carraway::Post.find(post.uid)
        expect(saved_post.published).to_not eq(nil)
        expect(saved_post.published_at).to eq(published_at)
        expect(last_response.header["Location"]).to be_end_with(post.uid)
      end
    end
  end

  describe 'PATCH /carraway/unpublish' do
    let!(:post) do
      Carraway::Post.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category',
        published: Time.now.to_i
      )
    end

    let(:params) do
      {
        uid: post.uid
      }
    end

    it do
      patch '/carraway/unpublish', params

      expect(last_response).to be_redirect

      saved_post = Carraway::Post.find(post.uid)
      expect(saved_post.published).to eq(nil)
      expect(last_response.header["Location"]).to be_end_with(post.uid)
    end
  end

  describe 'DELETE /carraway/destroy' do
    let!(:post) do
      Carraway::Post.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category',
      )
    end

    let(:params) do
      {
        uid: post.uid
      }
    end

    it do
      delete '/carraway/destroy', params

      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to be_end_with('/carraway/')
      expect(Carraway::Post.find(post.uid)).to eq(nil)
    end
  end

  describe 'GET /carraway/files' do
    let(:file) do
      Carraway::File.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end

    before do
      Carraway::FileRepository.new.save(file)
    end

    it do
      get "/carraway/files"
      expect(last_response).to be_ok
      expect(last_response.body).to include(file.path)
    end
  end

  describe 'POST /carraway/files' do
    let(:params) do
      {
        title: 'File title',
        file: { tempfile: '' }
      }
    end

    it do
      post '/carraway/files', params

      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to be_end_with('/carraway/files')

      repository = Carraway::FileRepository.new
      expect(repository.all.size).to eq(1)
      file = repository.all.last
      expect(file.title).to eq('File title')
    end
  end

  describe 'GET /carraway/files/:id' do
    let(:file) do
      Carraway::File.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end

    before do
      Carraway::FileRepository.new.save(file)
    end

    it do
      get "/carraway/files/#{file.uid}"
      expect(last_response).to be_ok
      expect(last_response.body).to include(file.path)
    end
  end

  describe 'PATCH /carraway/files/:id' do
    let(:file) do
      Carraway::File.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end
    let(:repository) { Carraway::FileRepository.new }

    before do
      repository.save(file)
    end

    let(:params) do
      { title: 'New Title' }
    end

    it do
      patch "/carraway/files/#{file.uid}", params
      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to be_end_with("/carraway/files/#{file.uid}")

      updated = repository.find(file.uid)
      expect(updated.title).to eq('New Title')
    end
  end

  describe 'DELETE /carraway/files/:id' do
    let(:file) do
      Carraway::File.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end
    let(:repository) { Carraway::FileRepository.new }

    before do
      repository.save(file)
    end

    it do
      delete "/carraway/files/#{file.uid}"

      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to be_end_with('/carraway/files')
      expect(repository.find(file.uid)).to eq(nil)
      expect(repository).to_not be_persisted(file)
    end
  end
end
