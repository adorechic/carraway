require 'aws-sdk-dynamodb'
require 'aws-sdk-s3'

module Carraway
  class File
    attr_reader :title, :uid, :created, :file

    def initialize(title:, file: nil, uid: nil, created: nil)
      @title = title
      @file = file
      @uid = uid || generate_uid
      @created = created
    end

    %i(created).each do |col|
      define_method("#{col}_at") do
        at = send(col)
        at && Time.at(at)
      end
    end

    def path
      ext = '.pdf' # FIXME Accept other type
      # Seems prefix does not have to required parameter
      [Config.file_backend['prefix'], '/', @uid, ext].join
    end

    private

    # FIXME duplicate impl on Post
    def generate_uid
      [Time.now.strftime('%Y%m%d%H%M%S'), "%05d" % rand(10000)].join
    end
  end
end
