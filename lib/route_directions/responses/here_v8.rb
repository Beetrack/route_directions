require 'route_directions/responses/base'
require 'route_directions/responses/route_leg'
require 'route_directions/errors'
require 'json'

module RouteDirections
  module Responses
    class HereV8 < Base
      private

      def process_response
        body = JSON.parse(@http_response.body)
        process_valid(body['routes'][0])
      end

      def process_valid(route_body)
        @time += route_body['sections'].sum { |section| section['summary']['duration'] }
        @distance += route_body['sections'].sum { |section| section['summary']['length'] }
        route_body['sections'].each_with_index do |leg_json, index|
          @route_legs << process_legs(leg_json, index)
        end
        @statuses += ['OK']
      end

      def process_legs(leg_json, index)
        leg = RouteLeg.new(
          leg_json['summary']['length'],
          leg_json['summary']['duration'],
          leg_json['polyline']
        )
        add_waypoints_to_route_leg(leg, index, nil)
      end

      def waypoint_new_order_by_index(index, _waypoints_json)
        waypoint_order_by_index(index)
      end
    end
  end
end
