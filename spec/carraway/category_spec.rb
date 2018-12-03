RSpec.describe Carraway::Category do
  before do
    Carraway::Config.load('spec/test.yml')
  end

  describe '.find' do
    it do
      category = Carraway::Category.find('test_category')
      expect(category.title).to eq('カテゴリータイトル')
      expect(category.key).to eq('test_category')
    end
  end

  describe '.all' do
    it do
      categories = Carraway::Category.all
      expect(categories.size).to eq(1)

      category = categories.first
      expect(category.title).to eq('カテゴリータイトル')
      expect(category.key).to eq('test_category')
    end
  end

  describe '#fullpath' do
    let(:category) do
      described_class.find('test_category')
    end

    it 'returns fullpath' do
      # FIXME this requres optional delimiter?
      expect(category.fullpath('uid')).to eq('category-pathuid')
    end
  end
end
