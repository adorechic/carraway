require 'aws-sdk-dynamodb'

module Carraway
  class Post
    class << self
      def setup
        client.create_table(
          attribute_definitions: [
            { attribute_name: :path, attribute_type: "S" },
          ],
          key_schema: [
            { attribute_name: :path, key_type: "HASH" },
          ],
          provisioned_throughput: {
            read_capacity_units: 5, # FIXME configurable
            write_capacity_units: 5, # FIXME configurable
          },
          table_name: Config.backend['table_name'],
        )
      end

      def drop
        client.delete_table(table_name: Config.backend['table_name'])
      end

      def create(title:, path:, body:, category_key:, at: Time.now)
        category = Category.find(category_key)
        # FIXME check path to prevent overwriting
        post = new(
          title: title,
          body: body,
          path: category.fullpath(path),
          category: category,
          created: at.to_i,
          updated: at.to_i
        )
        post.save(at: at)
        post
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

      def find(path)
        item = client.get_item(
          key: {
            path: path
          },
          table_name: Config.backend['table_name'],
        ).item
        if item
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

    attr_reader :title, :body, :path, :category, :created, :updated, :published

    def initialize(title:, body:, path:, category:, created:, updated:)
      @title = title
      @body = body
      @path = path
      @category = category
      @created = created
      @updated = updated
    end

    %i(created updated published).each do |col|
      define_method("#{col}_at") do
        at = send(col)
        at && Time.at(at)
      end
    end

    def assign(title:, body:)
      @title = title
      @body = body
    end

    def save(at: Time.now)
      self.class.client.put_item(
        table_name: Config.backend['table_name'],
        item: to_h.merge(updated: at.to_i)
      )
    end

    def destroy
      self.class.client.delete_item(
        table_name: Config.backend['table_name'],
        key: {
          path: @path
        }
      )
    end

    def to_h
      {
        title: @title,
        body: @body,
        path: @path,
        category: @category.key,
        created: @created.to_i,
        updated: @updated.to_i,
      }
    end
  end
end
