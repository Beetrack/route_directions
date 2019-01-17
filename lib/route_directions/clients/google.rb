require 'route_directions/clients/base'
require 'route_directions/responses/google'

module RouteDirections
  module Clients
    class Google < Base
      def response_class
        RouteDirections::Responses::Google
      end

      private

      def request(origin, waypoints, destination)
        Request.new(
          provider_url,
          parameters(origin, waypoints, destination)
        )
      end

      def provider_url
        'https://maps.googleapis.com/maps/api/directions/json'
      end

      def parameters(origin, waypoints, destination)
        required_parameters = {
          origin: origin.join(','),
          destination: destination.join(','),
          key: key
        }
        if waypoints.any?
          required_parameters[:waypoints] = waypoints
                                            .map { |point| point.join(',') }
                                            .join('|')
        end
        required_parameters
      end

      def valid?(response)
        !(['OVER_DAILY_LIMIT', 'OVER_QUERY_LIMIT'].include? response['status'])
      end

      def max_waypoints
        options[:max_waypoint_size] ||
          Configuration.instance.google_options.max_waypoint_size ||
          MAX_WAYPOINTS
      end

      def key
        options[:key] || Configuration.instance.google_options.key
      end
    end
  end
end
