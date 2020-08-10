require 'route_directions/clients/base'
require 'route_directions/responses/here'
require 'time'

module RouteDirections
  module Clients
    class Here < Base
      def response_class
        RouteDirections::Responses::Here
      end

      def max_waypoints
        options[:max_waypoint_size] ||
          Configuration.instance.here_options.max_waypoint_size ||
          MAX_WAYPOINTS
      end

      private

      def request(origin, waypoints, destination)
        Request.new(
          provider_url,
          parameters(origin, waypoints, destination),
          nil,
          max_tries
        )
      end

      def provider_url
        if options[:optimize]
          'https://wse.ls.hereapi.com/2/findsequence.json'
        else
          'https://route.ls.hereapi.com/routing/7.2/calculateroute.json'
        end
      end

      def parameters(origin, waypoints, destination)
        params = {
          mode: 'fastest;car;traffic:enabled'
        }

        params.merge!(auth_params)
        params.merge!(waypoints_params(origin, waypoints, destination))
        params.merge!(response_format_params)
        params.merge!(departure_time_params)
        params
      end

      def auth_params
        {
          apiKey: api_key
        }
      end

      def waypoints_params(origin, waypoints, destination)
        params = {}
        # origin
        params[waypoint_name_param(0, waypoints)] = waypoint_parser(*origin)
        # destination
        params[waypoint_name_param(waypoints.size + 1, waypoints)] =
          waypoint_parser(*destination)

        return params unless waypoints.any?

        waypoints.each_with_index do |point, i|
          params[waypoint_name_param(i + 1, waypoints)] =
            waypoint_parser(*point)
        end

        params
      end

      def response_format_params
        if options[:optimize]
          {}
        else
          {
            routeAttributes: 'none,waypoints,summary,shape,legs',
            legAttributes: 'none,waypoint,length,travelTime,shape'
          }
        end
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
          departure: time.strftime('%FT%T%:z')
        }
      end

      def abort?(response)
        ['REQUEST_DENIED'].include? response['status']
      end

      def waypoint_parser(latitude, longitude)
        "geo!#{latitude},#{longitude}"
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
