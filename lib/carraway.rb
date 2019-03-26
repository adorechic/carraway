module Carraway
  def self.working_dir
       Dir.pwd
  end
end

require 'carraway/version'
require 'carraway/category'
require 'carraway/post'
require 'carraway/file'
require 'carraway/file_repository'
require 'carraway/config'
require 'carraway/server'
