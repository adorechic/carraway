module Carraway
  class Category
    class << self
      def load(categories)
        @categories = categories.inject({}) do |hash, (key, attributes)|
          hash[key] = new(key: key, title: attributes['title'], dir: attributes['dir'])
          hash
        end
      end

      def find(key)
        @categories.fetch(key)
      end

      def all
        @categories.values
      end
    end

    attr_reader :key, :title

    def initialize(key:, title:, dir:)
      @key = key
      @title = title
      @dir = dir
    end

    def fullpath(uid)
      [@dir, uid].join
    end
  end
end
