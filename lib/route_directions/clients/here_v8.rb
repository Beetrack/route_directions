require 'route_directions/clients/base'
require 'route_directions/responses/here_v8'
require 'time'

module RouteDirections
  module Clients
    class HereV8 < Base
      def response_class
        RouteDirections::Responses::HereV8
      end

      def max_waypoints
        options[:max_waypoint_size] ||
          Configuration.instance.here_options.max_waypoint_size ||
          MAX_WAYPOINTS
      end

      private

      def request(origin, _waypoints, destination)
        Request.new(
          provider_url,
          parameters(origin, destination),
          nil,
          max_tries
        )
      end

      def provider_url
        if options[:optimize]
          'https://wse.ls.hereapi.com/2/findsequence.json'
        else
          'https://router.hereapi.com/v8/routes' + vias_parameter
        end
      end

      def vias_parameter
        return '' if waypoints.empty?

        '?' + waypoints.map { |point| "via=#{waypoint_parser(*point)}" }.join('&')
      end

      def parameters(origin, destination)
        params = {
          transportMode: 'car',
          routingMode: 'fast'
        }

        params.merge!(spans: 'length')
        params.merge!(return: 'summary,polyline')
        params.merge!(auth_params)
        params.merge!(waypoints_params(origin, destination))
        params.merge!(departure_time_params)
        params
      end

      def auth_params
        {
          apiKey: api_key
        }
      end

      def waypoints_params(origin, destination)
        {
          'origin': waypoint_parser(*origin),
          'destination': waypoint_parser(*destination)
        }
      end

      def departure_time_params
        partial_time = if options[:optimize]
                        options[:departure_time] || Time.now.to_i
                      else
                        options[:departure_time]
                      end

        return {} if partial_time.nil?

        time = if partial_time.is_a? Numeric
                Time.at(partial_time)
              else
                Time.parse(partial_time.to_s)
              end

        {
          departureTime: time.strftime('%FT%T%:z')
        }
      end

      def abort?(response)
        ['REQUEST_DENIED'].include? response['status']
      end

      def waypoint_parser(latitude, longitude)
        "#{latitude},#{longitude}"
      end

      def max_tries
        options[:max_retries] ||
          Configuration.instance.here_options.max_tries
      end

      def api_key
        options[:key] || Configuration.instance.here_options.key
      end

      def waypoint_name_param(index, waypoints)
        if options[:optimize]
          case index
          when 0
            :start
          when waypoints.size + 1
            :end
          else
            "destination#{index}".to_sym
          end
        else
          "waypoint#{index}".to_sym
        end
      end
    end
  end
end
