require 'route_directions/clients/base'
require 'route_directions/responses/google'

module RouteDirections
  module Clients
    class Google < Base
      MAX_WAYPOINTS = 9

      def response
        total_waypoints = if waypoints && waypoints.any?
                            [origin] + waypoints + [destination]
                          else
                            [origin, destination]
                          end

        google_response = RouteDirections::Responses::Google.new
        while (size = total_waypoints.size) > 1
          request = Request.new(
            provider_url,
            parameters(
              total_waypoints.shift,
              total_waypoints.take([MAX_WAYPOINTS, size - 2].min),
              total_waypoints.first
            )
          )
          google_response.http_response = request.execute
        end
        google_response
      end

      private

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
