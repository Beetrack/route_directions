require 'route_directions/clients/base'
require 'route_directions/responses/osrm'

module RouteDirections
  module Clients
    class Osrm < Base
      def response_class
        RouteDirections::Responses::Osrm
      end

      private

      def request(origin = nil, waypoints = nil, destination = nil, departure_time = nil)
        Request.new(
          provider_url(origin, waypoints, destination),
          parameters,
          max_tries
        )
      end

      def provider_url(origin = nil, waypoints = nil, destination = nil, departure_time = nil)
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

      def parameters(origin = nil, waypoints = nil, destination = nil, departure_time = nil)
        {}
      end

      def base_url
        host + '/route/v1/driving/'
      end

      def valid?(response)
        true
      end

      def abort?(response)
        false
      end

      def max_waypoints
        options[:max_waypoint_size] ||
          Configuration.instance.osrm_options.max_waypoint_size ||
          MAX_WAYPOINTS
      end

      def max_tries
        options[:max_retries] ||
          Configuration.instance.osrm_options.max_tries ||
          MAX_TRIES
      end

      def host
        options[:host] ||
          Configuration.instance.osrm_options.host ||
          'https://router.project-osrm.org'
      end
    end
  end
end
