require 'aws-sdk-dynamodb'

module Carraway
  class Post
    class << self
      def setup
        client.create_table(
          attribute_definitions: [
            { attribute_name: :path, attribute_type: "S" },
            { attribute_name: :updated, attribute_type: "N" },
          ],
          key_schema: [
            { attribute_name: :path, key_type: "HASH" },
            { attribute_name: :updated, key_type: "RANGE" },
          ],
          provisioned_throughput: {
            read_capacity_units: 5,
            write_capacity_units: 5,
          },
          table_name: Config.backend['table_name'],
        )
      end

      def drop
        client.delete_table(table_name: Config.backend['table_name'])
      end

      def create(title:, path:, body:, category_key:, at: Time.now)
        category = Category.find(category_key)
        item = {
          table_name: Config.backend['table_name'],
          item: {
            title: title,
            body: body,
            path: category.fullpath(path),
            category: category.key,
            created: at.to_i,
            updated: at.to_i
          }
        }
        client.put_item(item)
      end

      def all
        client.scan(table_name: Config.backend['table_name']).items.map do |item|
          new(
            title: item['title'],
            body: item['body'],
            path: item['path'],
            category: Category.find(item['category']),
            created: Time.at(item['created']),
            updated: Time.at(item['updated'])
          )
        end
      end

      private

      def client
        Aws::DynamoDB::Client.new(
          endpoint: Config.backend['endpoint'],
          region: Config.backend['region'],
          access_key_id: 'dummy',
          secret_access_key: 'dummy'
        )
      end
    end

    attr_reader :title, :body, :path, :category, :created, :updated

    def initialize(title:, body:, path:, category:, created:, updated:)
      @title = title
      @body = body
      @path = path
      @category = category
      @created = created
      @updated = updated
    end
  end
end
