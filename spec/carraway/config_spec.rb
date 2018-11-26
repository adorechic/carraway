RSpec.describe Carraway::Config do
  before do
    described_class.load('spec/test.yml')
  end

  describe '.backend' do
    subject { described_class.backend }

    it do
      expected = {
        'table_name' => 'test_table',
        'endpoint' => 'http://localhost:6000',
        'region' => 'dummy'
      }
      is_expected.to eq(expected)
    end
  end

  describe '.port' do
    subject { described_class.port }

    it do
      is_expected.to eq(5000)
    end
  end

  describe '.gatsby_endpoint' do
    subject { described_class.gatsby_endpoint }

    it do
      is_expected.to eq('http://localhost:8000')
    end
  end

  describe '.file_backend' do
    subject { described_class.file_backend }

    it do
      is_expected.to be_nil
    end
  end
end
