RSpec.describe Carraway::File do
  before do
    # FIXME Abstract as a repository
    Carraway::Post.setup
  end

  after do
    # FIXME Abstract as a repository
    Carraway::Post.drop
  end

  describe '#save' do
    before do
      # FIXME Do not use allow_any_instance_of
      s3_client = Aws::S3::Client.new(stub_responses: true)
      s3_client.stub_responses(:put_object, true)
      allow_any_instance_of(Carraway::File).to receive(:s3_client).and_return(s3_client)
    end

    let(:file) do
      described_class.new(
        title: 'Title',
        file: { tempfile: '' }
      )
    end

    it do
      file.save

      repository = Carraway::FileRepository.new
      expect(repository.all.size).to eq(1)

      found = repository.all.first
      expect(found.title).to eq('Title')
      expect(found.uid).to_not be_nil
      expect(found.created_at).to_not be_nil
      expect(found.path).to be_end_with("/#{found.uid}.pdf")
    end
  end
end
