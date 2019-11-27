require_relative 'helpers/toggles'
require_relative 'container'
require('sinatra/cross_origin')

class AssessorService < Sinatra::Base
  attr_reader :toggles

  def initialize(toggles = false)
    super

    @toggles = toggles || Toggles.new
    @container = Container.new
  end

  configure do
    enable :cross_origin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  get '/' do
    'Hello world!'
  end

  get '/healthcheck' do
    status 200
  end

  get '/schemes' do
    content_type :json

    @container.get_object(:get_all_schemes_use_case).execute.to_json
  end

  post '/schemes' do
    @container.get_object(:add_new_scheme_use_case).execute('CIBSE').to_json
  end
end
