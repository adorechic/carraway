require 'sinatra'

module Carraway
  class Server < Sinatra::Base
    get '/' do
      'Hello'
    end
  end
end
