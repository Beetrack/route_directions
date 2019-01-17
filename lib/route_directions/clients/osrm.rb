require 'route_directions/clients/base'
require 'route_directions/responses/osrm'

module RouteDirections
  module Clients
    class Osrm < Base
      def response_class
        RouteDirections::Responses::Osrm
      end

      private

      def request(origin, waypoints, destination)
        Request.new(
          provider_url(origin, waypoints, destination),
          parameters
        )
      end

      def provider_url(origin, waypoints, destination)
        coordinates = if waypoints && waypoints.any?
                        waypoints
                      else
                        []
                      end
        coordinates.insert(0, origin)
        coordinates.insert(-1, destination)
        base_url + coordinates.map { |point| point.reverse.join(',') }
                              .join(';')
      end

      def parameters
        {}
      end

      def base_url
        (options[:host] || 'https://router.project-osrm.org') +
          '/route/v1/driving/'
      end

      def valid?(response)
        true
      end
    end
  end
end
