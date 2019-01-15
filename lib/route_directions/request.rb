require 'net/http'

module RouteDirections
  class Request
    attr_reader :provider_url, :parameters

    def initialize(provider_url, parameters)
      @provider_url = provider_url
      @parameters = parameters
    end

    def execute
      uri = URI(provider_url)
      uri.query = URI.encode_www_form(parameters) if parameters.any?
      Net::HTTP.get_response(uri)
    end
  end
end
