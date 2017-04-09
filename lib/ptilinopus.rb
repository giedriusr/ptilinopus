require 'httparty'
require 'ptilinopus/version'

module Ptilinopus
  class API
    include HTTParty
    API_PATH = '/api/v1/'
    DEFAULT_HEADER = { 'Content-Type' => 'application/json' }

    attr_accessor :api_key

    default_timeout 10
    base_uri 'https://app.mailerlite.com'

    def initialize(api_key = nil)
      @api_key = api_key || self.class.api_key
    end

    def call(type, method, params = {})
      ensure_api_key(params)

      params = params.merge(apiKey: @api_key)
      self.class.send(type, API_PATH + method, body: params.to_json, headers: DEFAULT_HEADER)
    end

    private

    def ensure_api_key(params)
      unless @api_key || params[:apiKey]
        raise StandardError, 'You must set an api_key prior to making a call'
      end
    end

    class << self
      attr_accessor :api_key

      def method_missing(sym, *args, &block)
        new(self.api_key).send(sym, *args, &block)
      end
    end
  end
end
