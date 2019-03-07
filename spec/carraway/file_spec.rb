RSpec.describe Carraway::File do
  describe '#path' do
    let(:file) { Carraway::File.new(title: 'Title', ext: 'pdf') }

    it { expect(file.path).to be_end_with("/#{file.uid}.pdf") }
  end
end
