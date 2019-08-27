require 'route_directions/responses/base'
require 'route_directions/responses/route_leg'
require 'route_directions/errors'
require 'json'

module RouteDirections
  module Responses
    class Google < Base
      private

      def process_response
        body = JSON.parse(@http_response.body)
        if body['status'] == 'OK'
          process_valid(body['routes'][0])
        else
          process_error(body['status'])
        end
      end

      def process_valid(route_body)
        @time = route_body['legs'].reduce(@time) do |sum, value|
          sum + value['duration']['value']
        end
        @distance = route_body['legs'].reduce(@distance) do |sum, value|
          sum + value['distance']['value']
        end
        route_body['legs'].each_with_index do |leg, index|
          @route_legs << process_leg(leg, index, route_body['waypoint_order'])
        end
        @polyline += decode_polyline(route_body['overview_polyline']['points'])
        @statuses += ['OK']
      end

      def process_status_code(status)
        case status
        when 'NOT_FOUND', 'ZERO_RESULTS', 'MAX_ROUTE_LENGTH_EXCEEDED', 'MAX_WAYPOINTS_EXCEEDED'
          'NoResultsError'
        when 'OVER_DAILY_LIMIT', 'OVER_QUERY_LIMIT'
          'OverQueryLimitError'
        when 'REQUEST_DENIED', 'INVALID_REQUEST'
          'DeniedQueryError'
        when 'UNKNOWN_ERROR'
          'StandardError'
        else
          status
        end
      end

      def process_leg(leg_json, index, waypoints_json)
        step_data = process_step(leg_json)
        leg = RouteLeg.new(
          step_data[:distance],
          step_data[:duration],
          step_data[:polyline]
        )
        add_waypoints_to_route_leg(leg, index, waypoints_json)
      end

      def process_step(leg)
        response = { distance: 0, duration: 0, polyline: [] }
        leg['steps'].each do |step|
          response[:distance] += step['distance']['value'].to_f
          response[:duration] += step['duration']['value'].to_f
          response[:polyline] += decode_polyline(step['polyline']['points'])
        end
        response
      end

      def waypoint_new_order_by_index(index, waypoints_json)
        return waypoint_order_by_index(index) unless optimize?

        return waypoint_order_by_index(index) if index.zero?

        new_index = waypoints_json.index do |i|
          index == i + 1
        end

        return waypoint_order_by_index(index) if new_index.nil?

        waypoint_order_by_index(new_index + 1)
      end
    end
  end
end
