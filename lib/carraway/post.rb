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

      def create(title:, body:, category_key:, at: Time.now, published: nil, labels: nil)
        category = Category.find(category_key)
        # FIXME check path to prevent overwriting
        post = new(
          uid: generate_uid,
          title: title,
          body: body,
          category: category,
          labels: labels,
          created: at.to_i,
          updated: at.to_i,
          published: published
        )
        post.save(at: at)
        post
      end

      def all(published_only: false, include_file: false)
        filter_expressions = []
        expression_attribute_values = {}

        unless include_file
          filter_expressions << 'record_type = :type'
          expression_attribute_values.merge!(':type' => 'post')
        end

        if published_only
          filter_expressions << 'attribute_exists(published)'
          filter_expressions << '(NOT attribute_type(published, :t))'
          filter_expressions << 'published < :now'
          expression_attribute_values.merge!(':t' => 'NULL', ':now' => Time.now.to_i)
        end

        query = { table_name: Config.backend['table_name'] }
        unless filter_expressions.empty?
          query.merge!(
            filter_expression: filter_expressions.join(' AND '),
            expression_attribute_values: expression_attribute_values
          )
        end

        client.scan(query).items.map do |item|
          case item['record_type']
          when 'post'
            new(
              uid: item['uid'],
              title: item['title'],
              body: item['body'],
              labels: item['labels'],
              category: Category.find(item['category']),
              created: Time.at(item['created']),
              updated: Time.at(item['updated']),
              published: item['published'] && Time.at(item['published'])
            )
          when 'file'
            Carraway::File.new(
              uid: item['uid'],
              title: item['title'],
              created: item['created'],
              labels: item['labels'],
              published: item['published']
            )
          else
            raise 'Unknown record_type'
          end
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
            labels: item['labels'],
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
    attr_accessor :published, :labels

    def initialize(uid:, title:, body:, category:, created:, updated:, published:, labels: nil)
      @uid = uid
      @title = title
      @body = body
      @category = category
      @labels = labels
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

    def assign(title:, body:, labels: nil)
      @title = title
      @body = body
      @labels = labels
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
        labels: @labels,
        record_type: 'post',
        category: @category.key,
        created: @created.to_i,
        updated: @updated.to_i,
        published: @published && @published.to_i
      }
    end
  end
end
