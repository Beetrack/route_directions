require 'route_directions/providers/client'

module RouteDirections
  module Providers
    class Osrm < Client
      def provider_url
        coordinates = if waypoints && waypoints.any?
                        waypoints
                      else
                        []
                      end
        coordinates.insert(0, origin)
        coordinates.insert(0, destination)
        base_url + coordinates.map { |point| point.reverse.join(',') }
                              .join(';')
      end

      def parameters
        {}
      end

      private

      def base_url
        options[:server] || 'https://router.project-osrm.org/route/v1/driving'
      end
    end
  end
end
