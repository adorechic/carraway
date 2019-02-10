module Carraway
  class FileRepository
    def all
      query = { table_name: Config.backend['table_name'] }
      query[:filter_expression] = <<~FILTER
          record_type = :type
        FILTER
      query[:expression_attribute_values] = {
        ':type' => 'file'
      }

      client.scan(query).items.map do |item|
        Carraway::File.new(
          uid: item['uid'],
          title: item['title'],
          created: item['created']
        )
      end
    end

    def save(file, at: Time.now)
      client.put_item(
        table_name: Config.backend['table_name'],
        item: {
          uid: file.uid,
          record_type: 'file',
          title: file.title,
          created: at.to_i
        }
      )
      s3_client.put_object(
        body: file.file[:tempfile],
        bucket: Config.file_backend['bucket'],
        acl: 'public-read',
        key: file.path
      )
    end

    private

    def client
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

    def s3_client
      Aws::S3::Client.new
    end
  end
end
