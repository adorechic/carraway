require 'yaml'
require 'carraway/category'

module Carraway
  module Config
    class << self
      def load(file)
        config = YAML.load_file(file)
        Category.load(config['categories'])
      end
    end
  end
end
