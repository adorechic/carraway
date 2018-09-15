RSpec.describe Carraway::Config do
  before do
    described_class.load('spec/test.yml')
  end

  it 'returns backend' do
    expect(
      described_class.backend
    ).to eq(
           'table_name' => 'test_table'
         )
  end
end
