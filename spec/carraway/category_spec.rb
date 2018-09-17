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
end
