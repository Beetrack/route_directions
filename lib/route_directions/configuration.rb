require 'singleton'
require 'ostruct'

module RouteDirections
  AVAILABLE_PROVIDERS = %w[Google Osrm].freeze
  OPTION_KEYS = %w[key host max_waypoint_size max_tries].freeze

  def self.configure(options)
    Configuration.instance.options = options
  end

  class Configuration
    include Singleton

    attr_reader :default_provider

    def initialize
      @options = default_options
    end

    def options=(options)
      @options = default_options
      if options.key? :provider
        single_provider(options)
      elsif multiple_providers?(options)
        multiple_providers(options)
      end
    end

    AVAILABLE_PROVIDERS.each do |provider|
      define_method("#{provider.downcase}_options") do
        @options[provider.downcase.to_sym]
      end
    end

    private

    def default_options
      result = {}
      AVAILABLE_PROVIDERS.each do |provider|
        result[provider.downcase.to_sym] = OpenStruct.new
      end
      result
    end

    def multiple_providers?(options)
      AVAILABLE_PROVIDERS.any? do |provider|
        options.key? provider.downcase.to_sym
      end
    end

    def single_provider(options, provider = nil)
      provider ||= options.delete(:provider)
      options.select! { |key, _v| OPTION_KEYS.include? key.to_s }
      unless AVAILABLE_PROVIDERS.include? provider
        raise ArgumentError, 'Invalid provider'
      end
      @options[provider.downcase.to_sym] = OpenStruct.new(options)
      @default_provider = provider
    end

    def multiple_providers(options)
      shared_options = options.select { |key, _v| OPTION_KEYS.include? key.to_s }
      AVAILABLE_PROVIDERS.each do |provider|
        provider_symbol = provider.downcase.to_sym
        next unless options.key? provider_symbol
        single_provider(options[provider_symbol].merge(shared_options), provider)
      end
    end
  end
end
