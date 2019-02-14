require "spec_helper"

RSpec.describe Carraway::FileRepository do
  before do
    # FIXME Abstract as a repository
    Carraway::Post.setup
  end

  after do
    # FIXME Abstract as a repository
    Carraway::Post.drop
  end

  let(:repository) { described_class.new }

  describe '#save' do
    let(:file) do
      Carraway::File.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end

    it do
      repository.save(file, at: Time.now - 10)
      expect(repository.all.size).to eq(1)

      found = repository.all.first
      expect(found.title).to eq('Title')
      created = found.created
      found.title = 'New Title'

      repository.save(found)

      expect(repository.all.size).to eq(1)

      found = repository.all.first
      expect(found.title).to eq('New Title')
      expect(found.created).to eq(created)
    end
  end

  describe '#all' do
    let(:file) do
      Carraway::File.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end
    let!(:post) do
      Carraway::Post.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )
    end

    before do
      repository.save(file)
    end

    it 'returns file' do
      expect(repository.all.size).to eq(1)

      found = repository.all.first
      expect(found.title).to eq('Title')
      expect(found.uid).to_not be_nil
      expect(found.created_at).to_not be_nil
    end
  end

  describe '#find' do
    let(:file) do
      Carraway::File.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end
    let!(:post) do
      Carraway::Post.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )
    end

    before do
      repository.save(file)
    end

    it do
      found = repository.find(file.uid)
      expect(found.title).to eq(file.title)

      expect(repository.find('unknown')).to eq(nil)
      expect(repository.find(post.uid)).to eq(nil)
    end
  end
end
