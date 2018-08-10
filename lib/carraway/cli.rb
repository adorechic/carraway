require 'thor'

module Carraway
  class CLI < Thor
    desc 'start', 'Start server'
    def start
      puts 'Start server!'
    end
  end
end
