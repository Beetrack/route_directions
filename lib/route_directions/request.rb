require 'net/http'
require 'json'

module RouteDirections
  class Request
    MAX_TRIES = 3

    attr_reader :provider_url, :parameters

    def initialize(provider_url, parameters, tries)
      @provider_url = provider_url
      @parameters = parameters
      @max_tries = tries || MAX_TRIES
    end

    def execute
      uri = URI(provider_url)
      uri.query = URI.encode_www_form(parameters) if parameters.any?
      begin
        response = Net::HTTP.get_response(uri)
        case response
        when Net::HTTPSuccess
          response
        else
          retry_execute
        end
      rescue SocketError, Errno::ECONNREFUSED, Timeout::Error
        retry_execute
      end
    end

    private

    def retry_execute
      @retries = (@retries || @max_tries) - 1
      if @retries > 1
        sleep 1
        execute
      else
        Net::HTTPError.new('ErrorConnection', nil)
      end
    end
  end
end
