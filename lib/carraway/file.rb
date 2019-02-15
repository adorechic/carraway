require 'aws-sdk-dynamodb'
require 'aws-sdk-s3'

module Carraway
  class File
    attr_reader :uid, :created, :file, :published
    attr_accessor :title, :labels

    def initialize(title:, file: nil, uid: nil, created: Time.now.to_i, labels: nil, published: nil)
      @title = title
      @file = file
      @uid = uid || generate_uid
      @created = created
      @labels = labels
      @published = published || created
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

    def to_h
      {
        uid: @uid,
        title: @title,
        path: path,
        labels: @labels,
        record_type: 'file',
        created: @created.to_i,
        published: @published && @published.to_i
      }
    end

    private

    # FIXME duplicate impl on Post
    def generate_uid
      [Time.now.strftime('%Y%m%d%H%M%S'), "%05d" % rand(10000)].join
    end
  end
end
