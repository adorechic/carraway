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
end
