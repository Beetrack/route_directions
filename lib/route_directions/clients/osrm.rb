require 'route_directions/clients/base'
require 'route_directions/responses/osrm'

module RouteDirections
  module Clients
    class Osrm < Base
      def response
        request = Request.new(provider_url, parameters)
        RouteDirections::Responses::Osrm.new(request.execute)
      end

      private

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

      def base_url
        (options[:host] || 'https://router.project-osrm.org') +
          '/route/v1/driving/'
      end
    end
  end
end
