require 'route_directions/request'
require 'route_directions/configuration'

module RouteDirections
  module Clients
    class Base
      MAX_WAYPOINTS = 9
      MAX_TRIES = 3
      attr_reader :origin, :destination, :waypoints, :options

      def initialize(origin, destination, options)
        @origin = process_point_parameter(origin)
        @destination = process_point_parameter(destination)
        @waypoints = process_waypoints(options[:waypoints])
        @options = options
      end

      def response
        total_waypoints = whole_path
        response = response_class.new

        while (size = total_waypoints.size) > 1
          response.http_response = assure_response(
            total_waypoints.shift,
            total_waypoints.shift([max_waypoints, size - 2].min),
            total_waypoints.first
          )
        end

        response
      end

      private

      def valid?
        raise NotImplementedError, 'Called abstract method valid?'
      end

      def request
        raise NotImplementedError, 'Called abstract method request'
      end

      def provider_url
        raise NotImplementedError, 'Called abstract method provider_url'
      end

      def parameters
        raise NotImplementedError, 'Called abstract method parameters'
      end

      def max_waypoints
        raise NotImplementedError, 'Called abstract method max_waypoints'
      end

      def max_tries
        raise NotImplementedError, 'Called abstract method max_tries'
      end

      def key
        raise NotImplementedError, 'Called abstract method key'
      end

      def host
        raise NotImplementedError, 'Called abstract method host'
      end

      def assure_response(origin, waypoints, destination)
        response = request(origin, waypoints, destination).execute
        unless valid?(response)
          response = retry_request(origin, waypoints, destination)
        end
        response
      end

      def retry_request(origin, waypoints, destination)
        @retries = (@retries || max_tries) - 1
        if @retries > 1
          sleep 1
          assure_response(origin, waypoints, destination)
        else
          response  = {}
          response['status'] = "ANSWER_ERROR"
          response['code'] = "ANSWER_ERROR"
          response
        end
      end

      def whole_path
        if @waypoints && @waypoints.any?
          [@origin] + @waypoints + [@destination]
        else
          [@origin, @destination]
        end
      end

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
