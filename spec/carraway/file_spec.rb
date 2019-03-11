RSpec.describe Carraway::File do
  describe '#path' do
    let(:file) { Carraway::File.new(title: 'Title', ext: 'pdf') }

    it { expect(file.path).to be_end_with("/#{file.uid}.pdf") }

    context 'if previous record does not have ext attribute' do
      let(:file) { Carraway::File.new(title: 'Title') }

      it { expect(file.path).to be_end_with("/#{file.uid}.pdf") }
    end
  end
end
