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
          key: options[:key]
        }
        if waypoints.any?
          required_parameters[:waypoints] = waypoints
                                            .map { |point| point.join(',') }
                                            .join('|')
        end
        required_parameters
      end
    end
  end
end
