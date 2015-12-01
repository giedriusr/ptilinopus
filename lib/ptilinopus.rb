require 'httparty'
require 'ptilinopus/version'

module Ptilinopus
  class API
    include HTTParty
    DEFAULT_HEADER = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    API_PATH = '/api/v1/'

    attr_accessor :api_key

    default_timeout 10
    base_uri 'https://app.mailerlite.com'

    def initialize(api_key = nil)
      @api_key = api_key || self.class.api_key
    end

    def call(type, method, params = {})
      ensure_api_key(params)

      params = params.merge(apiKey: @api_key)
      response = self.class.send(type, API_PATH + method, body: params, headers: DEFAULT_HEADER, query_string_normalizer: query_string_normalizer)

      return response
    end

    private

    # FIXME Some methods of Mailerlite doesn't accept encoded emails
    def query_string_normalizer
      proc { |query|
        query.map do |key, value|
          "#{key}=#{value}"
        end.join('&')
      }
    end

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
