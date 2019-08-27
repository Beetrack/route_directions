require 'route_directions/responses/base'
require 'route_directions/responses/route_leg'
require 'route_directions/errors'
require 'json'

module RouteDirections
  module Responses
    class Osrm < Base
      private

      def process_response
        body = JSON.parse(@http_response.body)
        if body['code'] == 'Ok'
          process_valid(route_body(body), body['waypoints'])
        else
          process_error(body['code'])
        end
      end

      def process_valid(route_body, waypoints_json)
        @time += route_body['duration']
        @distance += route_body['distance']
        @statuses += ['OK']
        @polyline += decode_polyline(route_body['geometry'])
        route_body['legs'].each_with_index do |leg, i|
          @route_legs << process_leg(leg, i, waypoints_json)
        end
      end

      def process_status_code(status)
        case status
        when 'NoRoute'
          'NoResultsError'
        when 'InvalidUrl', 'InvalidService', 'InvalidVersion', 'InvalidOptions',
             'InvalidQuery', 'InvalidValue', 'NoSegment'
          'InvalidDataError'
        when 'TooBig'
          'OverQueryLimitError'
        else
          status
        end
      end

      def process_leg(leg_json, index, waypoints_json)
        leg = RouteLeg.new(
          leg_json['distance'].to_f,
          leg_json['duration'].to_f,
          process_step_polyline(leg_json)
        )
        add_waypoints_to_route_leg(leg, index, waypoints_json)
      end

      def process_step_polyline(leg)
        response = []
        leg['steps'].each do |step|
          response += decode_polyline(step['geometry'])
        end
        response
      end

      def route_body(json)
        if optimize?
          json['trips'][0]
        else
          json['routes'][0]
        end
      end

      def waypoint_new_order_by_index(index, waypoints_json)
        return waypoint_order_by_index(index) unless optimize?

        new_index = waypoints_json.index do |waypoint|
          waypoint['waypoint_index'] == index
        end
        waypoint_order_by_index(new_index)
      end
    end
  end
end
