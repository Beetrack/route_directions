require 'route_directions/request'

module RouteDirections
  module Providers
    class Client
      attr_reader :origin, :destination, :waypoints, :options

      def initialize(origin, destination, options)
        @origin = process_point_parameter(origin)
        @destination = process_point_parameter(destination)
        @waypoints = process_waypoints(options[:waypoints])
        @options = options
      end

      def response
        request = Request.new(provider_url, headers, body_parameters)
        request.execute
      end

      def provider_url
        raise NotImplementedError, 'Called abstract method provided_url'
      end

      def body_parameters
        raise NotImplementedError, 'Called abstract method parameters'
      end

      def headers
        raise NotImplementedError, 'Called abstract method provided_url'
      end

      private

      def process_waypoints(waypoints)
        return nil unless waypoints.respond_to? :map
        waypoints.map { |waypoint| process_point_parameter(waypoint) }
      end

      def process_point_parameter(parameter)
        unless parameter.respond_to? :[]
          raise ArgumentError, 'Invalid parameters for request directions'
        end
        validate_coordinates(parameter[0], parameter[1])
      end

      def validate_coordinates(latitude, longitude)
        is_latitude_valid = valid_coordinate?(latitude, 90)
        is_longitude_valid = valid_coordinate?(longitude, 180)

        if !is_latitude_valid || !is_longitude_valid
          raise ArgumentError, 'Invalid latitude or longitude value'
        end
        [latitude, longitude]
      end

      def valid_coordinate?(coordinate, max_value)
        coordinate.is_a?(Numeric) &&
          coordinate >= (-1 * max_value) &&
          coordinate <= max_value
      end
    end
  end
end
