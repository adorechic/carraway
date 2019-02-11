require 'yaml'

module Carraway
  module Config
    class << self
      def load(file)
        @config = YAML.load_file(file)
        Category.load(@config['categories'])
      end

      def backend
        @config['backend']
      end

      def port
        @config['port'] || 5000
      end

      def gatsby_endpoint
        @config['gatsby_endpoint'] || 'http://localhost:8000'
      end

      def file_backend
        @config['file_backend']
      end

      def labels
        @config['labels'] || {}
      end
    end
  end
end
