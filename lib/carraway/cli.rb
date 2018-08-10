require 'thor'
require 'carraway/server'

module Carraway
  class CLI < Thor
    desc 'start', 'Start server'
    def start
      Carraway::Server.run!
    end
  end
end
