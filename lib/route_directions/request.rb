require 'net/http'
require 'json'

module RouteDirections
  class Request
    MAX_TRIES = 3
    attr_reader :provider_url, :parameters

    def initialize(provider_url, parameters)
      @provider_url = provider_url
      @parameters = parameters
    end

    def execute
      uri = URI(provider_url)
      uri.query = URI.encode_www_form(parameters) if parameters.any?
      begin
        request = Net::HTTP.get_response(uri)
        assure_response(JSON.parse(request.body))
      rescue SocketError, Errno::ECONNREFUSED, Timeout::Error
        retry_execute
      end
    end

    private

    def assure_response(response)
      should_retry(response) ? retry_execute : response
    end

    def should_retry(response)
      ['OVER_DAILY_LIMIT', 'OVER_QUERY_LIMIT'].include? response['status']
    end

    def retry_execute
      @retries = (@retries || MAX_TRIES) - 1
      if @retries > 1
        execute
      else
        body = {}
        body['status'] = "CONNECTION_ERROR"
        body['code'] = "CONNECTION_ERROR"
        body
      end
    end
  end
end
