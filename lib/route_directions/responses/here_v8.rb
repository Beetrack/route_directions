require 'route_directions/responses/base'
require 'route_directions/responses/route_leg'
require 'route_directions/errors'
require 'route_directions/decoders/here_v8'
require 'json'

module RouteDirections
  module Responses
    class HereV8 < Base
      private

      def process_response
        body = JSON.parse(@http_response.body)
        if optimize?
          process_valid_optimized(body['results'][0])
        else
          process_valid(body['routes'][0])
        end
      end

      def process_valid_optimized(response_body)
        @time += response_body['time'].to_i
        @distance += response_body['distance'].to_i
        @statuses += ['OK']

        response_body['interconnections'].each_with_index do |leg, index|
          @route_legs << process_optimized_leg(leg, index, response_body['waypoints'])
        end
      end

      def process_optimized_leg(leg_json, index, waypoints_json)
        leg = RouteLeg.new(
          leg_json['distance'],
          leg_json['time'],
          nil
        )
        add_waypoints_to_route_leg(leg, index, waypoints_json)
      end

      def process_valid(route_body)
        @time += route_body['sections'].sum { |section| section['summary']['duration'] }
        @distance += route_body['sections'].sum { |section| section['summary']['length'] }
        route_body['sections'].each_with_index do |leg_json, index|
          polyline = Decoders::HereV8.new(leg_json['polyline']).decode
          @route_legs << process_legs(leg_json, index, polyline)
          @polyline << polyline
        end
        @statuses += ['OK']
      end

      def process_legs(leg_json, index, polyline)
        leg = RouteLeg.new(
          leg_json['summary']['length'],
          leg_json['summary']['duration'],
          polyline
        )
        add_waypoints_to_route_leg(leg, index, nil)
      end

      def waypoint_new_order_by_index(index, waypoints_json)
        return waypoint_order_by_index(index) unless optimize?

        waypoint_id = waypoints_json[index]['id']
        original_index = case waypoint_id
                         when 'start'
                           0
                         when 'end'
                           waypoints_json.size - 1
                         else
                           waypoint_id.delete('destination').to_i
                         end
        waypoint_order_by_index(original_index)
      end
    end
  end
end
