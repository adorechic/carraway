require 'thor'

module Carraway
  class CLI < Thor
    desc 'start', 'Start server'
    option :config, default: 'carraway.yml', aliases: 'c', type: :string
    def start
      Carraway::Config.load(options[:config])
      Carraway::Server.run!
    end


    desc 'setup', 'Setup backend'
    option :config, default: 'carraway.yml', aliases: 'c', type: :string
    def setup
      Carraway::Config.load(options[:config])
      Carraway::Post.setup
    end
  end
end
