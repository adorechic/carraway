require 'aws-sdk-dynamodb'

module Carraway
  class Post
    class << self
      def setup
        client.create_table(
          attribute_definitions: [
            { attribute_name: :uid, attribute_type: "S" },
          ],
          key_schema: [
            { attribute_name: :uid, key_type: "HASH" },
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

      def generate_uid
        [Time.now.strftime('%Y%m%d%H%M%S'), "%05d" % rand(10000)].join
      end

      def create(title:, body:, category_key:, at: Time.now)
        category = Category.find(category_key)
        # FIXME check path to prevent overwriting
        post = new(
          uid: generate_uid,
          title: title,
          body: body,
          category: category,
          created: at.to_i,
          updated: at.to_i,
          published: nil
        )
        post.save(at: at)
        post
      end

      def all(published_only: false)
        query = { table_name: Config.backend['table_name'] }
        if published_only
          query[:filter_expression] = <<~FILTER
            attribute_exists(published)
            AND (NOT attribute_type(published, :t))
            AND published < :now
          FILTER
          query[:expression_attribute_values] = { ':t' => 'NULL', ':now' => Time.now.to_i }
        end

        client.scan(query).items.map do |item|
          new(
            uid: item['uid'],
            title: item['title'],
            body: item['body'],
            category: Category.find(item['category']),
            created: Time.at(item['created']),
            updated: Time.at(item['updated']),
            published: item['published'] && Time.at(item['published'])
          )
        end
      end

      def find(uid)
        item = client.get_item(
          key: {
            uid: uid
          },
          table_name: Config.backend['table_name'],
        ).item
        if item
          new(
            uid: item['uid'],
            title: item['title'],
            body: item['body'],
            category: Category.find(item['category']),
            created: Time.at(item['created']),
            updated: Time.at(item['updated']),
            published: item['published'] && Time.at(item['published'])
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

    attr_reader :uid, :title, :body, :category, :created, :updated
    attr_accessor :published

    def initialize(uid:, title:, body:, category:, created:, updated:, published:)
      @uid = uid
      @title = title
      @body = body
      @category = category
      @created = created
      @updated = updated
      @published = published
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
          uid: @uid
        }
      )
    end

    def path
      @category.fullpath(@uid)
    end

    def to_h
      {
        uid: @uid,
        title: @title,
        body: @body,
        path: path,
        record_type: 'post',
        category: @category.key,
        created: @created.to_i,
        updated: @updated.to_i,
        published: @published && @published.to_i
      }
    end
  end
end
