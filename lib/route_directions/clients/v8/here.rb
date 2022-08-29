require 'route_directions/clients/base'
require 'route_directions/responses/v8/here'
require 'time'

module RouteDirections
  module Clients
    module V8
      class Here < Base
        def response_class
          RouteDirections::Responses::V8::Here
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
            'https://router.hereapi.com/v8/routes' + vias_parameter
          end
        end

        def vias_parameter
          return '' if waypoints.empty?

          waypoints.map { |point| "via=#{waypoint_parser(*point)}" }.join('&')
        end

        def parameters(origin, waypoints, destination)
          params = {
            transportMode: 'car',
            routingMode: 'fast'
          }

          params.merge!(spans: 'length')

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
          params['origin'] = waypoint_parser(*origin)
          params['destination'] = waypoint_parser(*destination)
          params
        end

        def response_format_params
          if options[:optimize]
            {}
          else
            {
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
end
