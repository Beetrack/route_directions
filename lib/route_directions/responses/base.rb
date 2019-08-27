require 'net/http'
require 'fast-polylines'

module RouteDirections
  module Responses
    class Base
      DEFAULT_TIME = 20
      DEFAULT_DISTANCE = 100
      ADMISSIBLE = 0.75

      attr_reader :distance, :time, :polyline, :status, :status_code,
                  :route_legs
      attr_reader :http_response

      def initialize(client_context)
        @client_context = client_context
        @time = 0
        @distance = 0
        @current_iteration = 0
        @polyline = []
        @statuses = []
        @route_legs = []
      end

      def http_response=(http_response)
        @http_response = http_response
        if http_response && http_response.message == 'ErrorConnection'
          process_error('ErrorConnection')
        elsif http_response
          process_response
        end
        @current_iteration += 1
        update_status
      end

      def errors
        @statuses.reject { |status| status == 'OK' }
      end

      private

      def process_response
        raise NotImplementedError, 'Called abstract method process_response'
      end

      def process_valid
        raise NotImplementedError, 'Called abstract method process_valid'
      end

      def process_status_code
        raise NotImplementedError, 'Called abstract method process_status_code'
      end

      def process_error(error)
        @time += DEFAULT_TIME
        @distance += DEFAULT_DISTANCE
        @statuses += [process_status_code(error)]
      end

      def update_status
        valids = @statuses.select { |status| status == 'OK' }.size

        if valids == @statuses.size
          @status = 'OK'
          @status_code = 200
        elsif valids >= (ADMISSIBLE * @statuses.size)
          @status = 'Approached'
          @status_code = 206
        else
          @status = 'Error'
          @status_code = 408
        end
      end

      def decode_polyline(polyline)
        FastPolylines::Decoder.decode(polyline)
      end

      def add_waypoints_to_route_leg(route_leg, index, waypoints_json)
        order = waypoint_order_by_index(index)
        origin_order = waypoint_new_order_by_index(index, waypoints_json)
        destination_order = waypoint_new_order_by_index(index + 1, waypoints_json)
        route_leg.origin_waypoint = {
          origin_waypoint: waypoint_by_index(origin_order),
          original_order: origin_order, current_order: order
        }
        route_leg.destination_waypoint = {
          destination_waypoint: waypoint_by_index(destination_order),
          original_order: destination_order, current_order: order + 1
        }
        route_leg
      end

      def waypoint_by_index(index)
        all_waypoints[index]
      end

      def waypoint_order_by_index(index)
        @current_iteration * (@client_context.max_waypoints + 1) +
          index
      end

      def all_waypoints
        @all_waypoints ||= begin
          [@client_context.origin] +
            @client_context.waypoints +
            [@client_context.destination]
        end
      end

      def optimize?
        @client_context.options[:optimize]
      end
    end
  end
end
