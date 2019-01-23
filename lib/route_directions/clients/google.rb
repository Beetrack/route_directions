require 'route_directions/clients/base'
require 'route_directions/responses/google'

module RouteDirections
  module Clients
    class Google < Base
      def response_class
        RouteDirections::Responses::Google
      end

      private

      def request(origin = nil, waypoints = nil, destination = nil, departure_time = nil)
        Request.new(
          provider_url,
          parameters(origin, waypoints, destination, departure_time),
          max_tries
        )
      end

      def provider_url(origin = nil, waypoints = nil, destination = nil, departure_time = nil)
        'https://maps.googleapis.com/maps/api/directions/json'
      end

      def parameters(origin = nil, waypoints = nil, destination = nil, departure_time = nil)
        required_parameters = {
          origin: origin.join(','),
          destination: destination.join(','),
          key: key,
          departure_time: departure_time
        }
        if waypoints.any?
          required_parameters[:waypoints] = waypoints
                                            .map { |point| point.join(',') }
                                            .join('|')
        end

        required_parameters
      end

      def valid?(response)
        !(['OVER_QUERY_LIMIT'].include? response['status'])
      end

      def abort?(response)
        ['REQUEST_DENIED'].include? response['status']
      end

      def max_waypoints
        options[:max_waypoint_size] ||
          Configuration.instance.google_options.max_waypoint_size ||
          MAX_WAYPOINTS
      end

      def max_tries
        options[:max_retries] ||
          Configuration.instance.google_options.max_tries ||
          MAX_TRIES
      end

      def key
        options[:key] || Configuration.instance.google_options.key
      end
    end
  end
end
