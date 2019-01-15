require 'route_directions/clients/base'

module RouteDirections
  module Clients
    class Google < Base
      def provider_url
        'https://maps.googleapis.com/maps/api/directions/json'
      end

      def parameters
        required_parameters = {
          origin: origin.join(','),
          destination: destination.join(','),
          key: options[:key]
        }
        if waypoints && waypoints.any?
          required_parameters[:waypoints] = waypoints
                                            .map { |point| point.join(',') }
                                            .join('|')
        end
        required_parameters
      end
    end
  end
end
