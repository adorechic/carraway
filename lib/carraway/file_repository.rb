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
  end
end
