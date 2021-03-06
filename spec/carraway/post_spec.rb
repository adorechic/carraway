RSpec.describe Carraway::Post do
  before do
    described_class.setup
  end

  after do
    described_class.drop
  end

  describe '.create' do
    it 'persists a new post' do
      created = described_class.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )

      expect(created.title).to eq('Post title')
      expect(created.body).to eq('This is an article.')

      all = described_class.all
      expect(all.size).to eq(1)
      expect(all.first.title).to eq(created.title)
      expect(all.first.body).to eq(created.body)
      expect(all.first.uid).to_not eq(nil)

      found = described_class.find(all.first.uid)
      expect(found.title).to eq(created.title)
      expect(found.body).to eq(created.body)
      expect(found.published).to eq(nil)
    end
  end

  describe '#save' do
    let(:post) do
      described_class.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )
    end

    it 'updates persited post' do
      post.assign(title: 'New title', body: 'New body')
      post.save

      persisted = described_class.find(post.uid)
      expect(persisted.title).to eq('New title')
      expect(persisted.body).to eq('New body')
    end

    it 'updates timestamp' do
      current = Time.now

      post.save(at: current)

      expect(post.updated).to eq(current.to_i)
      expect(post.updated_at.to_s).to eq(current.to_s)
    end
  end

  describe '#destroy' do
    let(:post) do
      described_class.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )
    end

    it 'removes an post' do
      post.destroy

      expect(described_class.all).to eq([])
    end
  end

  describe '.all' do
    let!(:published_post) do
      described_class.create(
        title: 'Published post',
        body: 'This is an article.',
        category_key: 'test_category',
        published: Time.now.to_i - 1
      )
    end

    let!(:unpublished_post) do
      described_class.create(
        title: 'Unpublished post',
        body: 'This is an article.',
        category_key: 'test_category',
      )
    end
    let(:file) do
      Carraway::File.new(
        title: 'File Title',
        file: { tempfile: '' },
        published: Time.now.to_i - 1
      )
    end

    before do
      Carraway::FileRepository.new.save(file)
    end

    it 'returns all posts' do
      post_uids = described_class.all.map(&:uid)

      expect(post_uids.size).to eq(2)
      expect(post_uids).to be_include(published_post.uid)
      expect(post_uids).to be_include(unpublished_post.uid)
      expect(post_uids).to_not be_include(file.uid)
    end

    it 'returns published posts with published_only' do
      post_uids = described_class.all(published_only: true).map(&:uid)

      expect(post_uids.size).to eq(1)
      expect(post_uids).to be_include(published_post.uid)
      expect(post_uids).to_not be_include(unpublished_post.uid)
      expect(post_uids).to_not be_include(file.uid)
    end

    it 'returns posts and files with include_file' do
      post_uids = described_class.all(include_file: true).map(&:uid)

      expect(post_uids.size).to eq(3)
      expect(post_uids).to be_include(published_post.uid)
      expect(post_uids).to be_include(unpublished_post.uid)
      expect(post_uids).to be_include(file.uid)
    end

    it 'returns published posts and files with include_file and published_only' do
      post_uids = described_class.all(include_file: true, published_only: true).map(&:uid)

      expect(post_uids.size).to eq(2)
      expect(post_uids).to be_include(published_post.uid)
      expect(post_uids).to_not be_include(unpublished_post.uid)
      expect(post_uids).to be_include(file.uid)
    end
  end

  describe '#path' do
    let(:post) do
      described_class.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )
    end
    let(:category) do
      Carraway::Category.find('test_category')
    end

    it 'returns http path' do
      expect(post.path).to eq(category.fullpath(post.uid))
    end
  end

  describe '#to_h' do
    let(:post) do
      described_class.create(
        title: 'Post title',
        body: 'This is an article.',
        category_key: 'test_category'
      )
    end

    it 'returns hash describing' do
      expect(
        post.to_h.slice(:title, :body)
      ).to eq(
             title: 'Post title',
             body: 'This is an article.'
           )
    end
  end
end
