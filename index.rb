require 'json'
require 'mongo'
require 'rack/parser'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'
require 'yaml'

# because Mongo messages get annoying
Mongo::Logger.logger.level = ::Logger::FATAL

class MyMICDS < Sinatra::Base
  CONFIG = YAML.load_file(File.expand_path('../config.yml', __FILE__))
  DB = Mongo::Client.new(CONFIG['mongodb']['uri'])

  configure do
    disable :protection

    require_relative 'lib/jwt'
    use JWT::Middleware

    use Rack::Parser
    register Sinatra::Namespace

    %w(
      auth
      users
    ).each do |section|
      require_relative "routes/#{section}"
      register const_get(section.capitalize + 'Routes')
    end
  end

  # all errors should be handled in the routes
  # and information should be returned accordingly
end
