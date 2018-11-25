RSpec.describe Carraway::Config do
  before do
    described_class.load('spec/test.yml')
  end

  describe '.backend' do
    subject { described_class.backend }

    it do
      is_expected.to eq('table_name' => 'test_table')
    end
  end
end
