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
          Configuration.instance.herev8_options.max_waypoint_size ||
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
          'https://wps.hereapi.com/v8/findsequence2'
        else
          'https://router.hereapi.com/v8/routes'
        end
      end

      def parameters(origin, waypoints, destination)
        params = {
          transportMode: 'car',
          routingMode: 'fast'
        }

        params.merge!(spans: 'length')
        params.merge!(return: 'summary,polyline')
        params.merge!(auth_params)
        params.merge!(waypoints_params(origin, waypoints, destination))
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

        if options[:optimize]
          params[waypoint_name_param(0, waypoints)] = waypoint_parser(*origin)
          params[waypoint_name_param(waypoints.size + 1, waypoints)] = waypoint_parser(*destination)

          return params unless waypoints.any?

          waypoints.each_with_index do |point, i|
            params[waypoint_name_param(i + 1, waypoints)] = waypoint_parser(*point)
          end
        else
          params[:origin] = waypoint_parser(*origin)
          params[:destination] = waypoint_parser(*destination)
          params[:via] = waypoints.map { |point| waypoint_parser(*point) }
        end

        params
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
          Configuration.instance.herev8_options.max_tries
      end

      def api_key
        options[:key] || Configuration.instance.herev8_options.key
      end

      def waypoint_name_param(index, waypoints)
        case index
        when 0
          :start
        when waypoints.size + 1
          :end
        else
          "destination#{index}".to_sym
        end
      end
    end
  end
end
