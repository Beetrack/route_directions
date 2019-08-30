require 'net/http'
require 'json'

module RouteDirections
  class Request
    MAX_TRIES = 3
    SLEEP_BASE = 0.2
    TIMEOUT = 30

    attr_reader :provider_url, :parameters, :headers

    def initialize(provider_url, parameters, headers, tries)
      @provider_url = provider_url
      @parameters = parameters
      @headers = headers
      @max_tries = tries || MAX_TRIES
    end

    def execute
      http, path = assemble_http_and_path
      execute_request(http, path)
    end

    private

    def assemble_http_and_path
      uri = URI(provider_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.read_timeout = TIMEOUT
      http.open_timeout = TIMEOUT
      path = uri.path
      path += "?#{URI.encode_www_form(parameters)}" if parameters.any?
      [http, path]
    end

    def execute_request(http, path)
      response = http.get(path, headers)

      if response.is_a? Net::HTTPSuccess
        response
      else
        retry_execute
      end
    rescue SocketError, Errno::ECONNREFUSED, Timeout::Error
      retry_execute
    end

    def retry_execute
      @retries ||= @max_tries
      @retries -= 1
      if @retries > 0
        sleep(SLEEP_BASE * (@max_tries - @retries))
        execute
      else
        Net::HTTPError.new('ErrorConnection', nil)
      end
    end
  end
end
