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

    before do
      # FIXME Do not use allow_any_instance_of
      s3_client = Aws::S3::Client.new(stub_responses: true)
      s3_client.stub_responses(:put_object, true)
      allow_any_instance_of(Carraway::File).to receive(:s3_client).and_return(s3_client)
      file.save
    end

    it 'returns file' do
      repository = described_class.new
      expect(repository.all.size).to eq(1)

      found = repository.all.first
      expect(found.title).to eq('Title')
    end
  end
end
