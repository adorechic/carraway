require 'thor'
require 'carraway/config'
require 'carraway/server'

module Carraway
  class CLI < Thor
    desc 'start', 'Start server'
    option :config, default: 'carraway.yml', aliases: 'c', type: :string
    def start
      Carraway::Config.load(options[:config])
      Carraway::Server.run!
    end
  end
end
