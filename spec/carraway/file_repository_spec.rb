require "spec_helper"

RSpec.describe Carraway::FileRepository do
  before do
    # FIXME Abstract as a repository
    Carraway::Post.setup
  end

  after do
    # FIXME Abstract as a repository
    Carraway::Post.drop
  end

  describe '#all' do
    let(:file) do
      Carraway::File.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end

    let(:repository) { described_class.new }

    before do
      # FIXME DRY
      s3_client = Aws::S3::Client.new(stub_responses: true)
      s3_client.stub_responses(:put_object, true)
      allow(repository).to receive(:s3_client).and_return(s3_client)
      repository.save(file)
    end

    it 'returns file' do
      expect(repository.all.size).to eq(1)

      found = repository.all.first
      expect(found.title).to eq('Title')
      expect(found.uid).to_not be_nil
      expect(found.created_at).to_not be_nil
    end
  end
end
