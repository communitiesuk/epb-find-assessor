# frozen_string_literal: true

require_relative 'helper/toggles'
require_relative 'container'
require 'sinatra/cross_origin'

class AssessorService < Sinatra::Base
  STATUS_CODES = {
    '400' => [
      PG::UniqueViolation,
      ActiveRecord::RecordNotUnique
    ],
    '401' => [
      JSON::ParserError
    ]
  }.freeze

  attr_reader :toggles

  def initialize(toggles = false)
    super

    @toggles = toggles || Toggles.new
    @container = Container.new
  end

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
    also_reload 'lib/**/*.rb'
  end

  configure do
    enable :cross_origin
    set :protection, except: [:remote_token]
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Cache-Control, Accept'
  end

  options '*' do
    response.headers['Allow'] = 'HEAD,GET,PUT,DELETE,OPTIONS'
    200
  end

  get '/' do
    redirect '/api'
  end

  get '/api' do
    content_type :json

    {
      links: {
        apispec: "https://mhclg-epb-swagger.london.cloudapps.digital"
      }
    }.to_json
  end

  get '/healthcheck' do
    status 200
  end

  get '/api/schemes' do
    content_type :json
    @container.get_object(:get_all_schemes_use_case).execute.to_json
  end

  post '/api/schemes' do
    content_type :json
    request_body = JSON.parse(request.body.read.to_s)
    result = @container.get_object(:add_new_scheme_use_case).execute(request_body['name']).to_json

    status 201
    result
  rescue StandardError => e
    handle_exception(e)
  end

  put '/api/schemes/:scheme_id/assessors/:scheme_assessor_id' do

    result = @container.get_object(:add_assessor_use_case).execute(params['scheme_id'], params['scheme_assessor_id'], JSON.parse(request.body.read.to_s)).to_json
    status 201
    result
  rescue UseCase::AddAssessor::SchemeNotFoundException
    status 404
  end

  private

  def handle_exception(error)
    return status 400 if STATUS_CODES['400'].include?(error.class)
    return status 401 if STATUS_CODES['401'].include?(error.class)

    status 500
  end
end
