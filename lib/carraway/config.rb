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
    end
  end
end
