require 'spec_helper'

RSpec.describe Carraway::Server, type: :request do
  describe 'GET /' do
    it do
      get '/'
      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to be_end_with('/carraway/')
    end
  end
end
