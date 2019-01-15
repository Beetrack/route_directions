require 'net/http'

module RouteDirections
  class Request
    attr_reader :provider_url, :parameters

    def initialize(provider_url, parameters)
      @provider_url = provider_url
      @parameters = parameters
    end

    def execute
      puts 'hola'
      puts provider_url
      puts parameters
    end
  end
end
