require 'aws-sdk-dynamodb'
require 'aws-sdk-s3'

module Carraway
  class File
    class << self
      def all
        query = { table_name: Config.backend['table_name'] }
        query[:filter_expression] = <<~FILTER
          record_type = :type
        FILTER
        query[:expression_attribute_values] = { ':type' => 'file' }

        dynamo_client.scan(query).items.map do |item|
          new(
            uid: item['uid'],
            title: item['title'],
            created: item['created']
          )
        end
      end

      def dynamo_client
        if Config.backend['endpoint']
          Aws::DynamoDB::Client.new(
            endpoint: Config.backend['endpoint'],
            region: Config.backend['region'],
            access_key_id: 'dummy',
            secret_access_key: 'dummy'
          )
        else
          Aws::DynamoDB::Client.new
        end
      end
    end

    attr_reader :title, :uid, :created

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

    # FIXME duplicate impl on Post
    def generate_uid
      [Time.now.strftime('%Y%m%d%H%M%S'), "%05d" % rand(10000)].join
    end

    def s3_client
      Aws::S3::Client.new
    end

    def path
      ext = '.pdf' # FIXME Accept other type
      [Config.file_backend['prefix'], '/', @uid, ext].join
    end

    def save(at = Time.now)
      self.class.dynamo_client.put_item(
        table_name: Config.backend['table_name'],
        item: {
          uid: @uid,
          record_type: 'file',
          title: @title,
          created: at.to_i
        }
      )
      s3_client.put_object(
        body: @file[:tempfile],
        bucket: Config.file_backend['bucket'],
        acl: 'public-read',
        key: path
      )
    end
  end
end
