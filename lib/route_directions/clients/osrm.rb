require 'route_directions/clients/base'

module RouteDirections
  module Clients
    class Osrm < Base
      def provider_url
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

      private

      def base_url
        (options[:host] || 'https://router.project-osrm.org') +
          '/route/v1/driving/'
      end
    end
  end
end
