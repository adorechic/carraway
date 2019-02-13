require 'thor'

module Carraway
  class CLI < Thor
    desc 'start', 'Start server'
    option :config, default: 'carraway.yml', aliases: 'c', type: :string
    def start
      Carraway::Config.load(options[:config])
      Carraway::Server.run!(port: Config.port)
    end


    desc 'setup', 'Setup backend'
    option :config, default: 'carraway.yml', aliases: 'c', type: :string
    def setup
      Carraway::Config.load(options[:config])
      Carraway::Post.setup
      Carraway::FileRepository.new.setup
    end

    desc 'drop', 'Drop backend'
    option :config, default: 'carraway.yml', aliases: 'c', type: :string
    def drop
      Carraway::Config.load(options[:config])
      Carraway::Post.drop
      Carraway::FileRepository.new.drop
    end
  end
end
