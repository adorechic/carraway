require 'aws-sdk-dynamodb'

module Carraway
  class Post
    class << self
      def setup
        client = Aws::DynamoDB::Client.new(
          endpoint: Config.backend['endpoint'],
          region: Config.backend['region'],
          access_key_id: 'dummy',
          secret_access_key: 'dummy'
        )

        client.create_table(
          attribute_definitions: [
            { attribute_name: "Path", attribute_type: "S" },
            { attribute_name: "Updated", attribute_type: "N" },
          ],
          key_schema: [
            { attribute_name: "Path", key_type: "HASH" },
            { attribute_name: "Updated", key_type: "RANGE" },
          ],
          provisioned_throughput: {
            read_capacity_units: 5,
            write_capacity_units: 5,
          },
          table_name: Config.backend['table_name'],
        )
      end
    end
  end
end
