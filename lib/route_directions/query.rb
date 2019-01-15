module RouteDirections
  class Query
    AVAILABLE_PROVIDERS = %w[Google Osrm].freeze

    attr_reader :client

    def initialize(origin, destination, options)
      opt = default_options.merge options
      provider = opt.delete(:provider)
      unless AVAILABLE_PROVIDERS.include? provider
        raise ArgumentError, 'Invalid provider'
      end

      require "route_directions/clients/#{provider.downcase}"
      @client = RouteDirections::Clients.const_get(provider)
                                        .new(origin, destination, opt)
    end

    def execute
      client.response
    end

    private

    def default_options
      {
        provider: 'Google'
      }
    end
  end
end
