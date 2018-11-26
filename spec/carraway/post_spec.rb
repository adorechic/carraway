RSpec.describe Carraway::Post do
  before do
    described_class.setup
  end

  after do
    described_class.drop
  end

  describe '.create' do
    it do
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
end
