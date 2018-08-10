module Carraway
  class Category
    class << self
      def load(categories)
        @categories = categories.inject({}) do |hash, (key, attributes)|
          hash[key] = new(title: attributes['title'])
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

    attr_reader :title

    def initialize(title:)
      @title = title
    end
  end
end
