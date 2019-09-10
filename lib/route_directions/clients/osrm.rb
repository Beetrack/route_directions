require 'route_directions/clients/base'
require 'route_directions/responses/osrm'

module RouteDirections
  module Clients
    class Osrm < Base
      def response_class
        RouteDirections::Responses::Osrm
      end

      def max_waypoints
        options[:max_waypoint_size] ||
          Configuration.instance.osrm_options.max_waypoint_size ||
          MAX_WAYPOINTS
      end

      private

      def request(origin, waypoints, destination)
        Request.new(
          provider_url(origin, waypoints, destination),
          parameters,
          headers,
          max_tries
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
        if options[:optimize]
          { steps: true, destination: 'last', source: 'first', roundtrip: false }
        else
          { steps: true }
        end
      end

      def base_url
        if options[:optimize]
          host + '/trip/v1/driving/'
        else
          host + '/route/v1/driving/'
        end
      end

      def abort?(_response)
        false
      end

      def max_tries
        options[:max_retries] ||
          Configuration.instance.osrm_options.max_tries
      end

      def host
        options[:host] ||
          Configuration.instance.osrm_options.host ||
          'https://router.project-osrm.org'
      end

      def headers
        options[:headers] ||
          Configuration.instance.osrm_options.headers
      end
    end
  end
end
