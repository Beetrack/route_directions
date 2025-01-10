module RouteDirections
  module Responses
    class RouteLeg
      attr_reader :distance, :time, :polyline,
                  :origin_waypoint, :destination_waypoint

      def initialize(distance, time, polyline)
        @distance = distance
        @time = time
        @polyline = polyline
      end

      def origin_waypoint=(opts)
        @origin_waypoint = create_waypoint(
          opts[:origin_waypoint],
          opts[:original_order],
          opts[:current_order]
        )
      end

      def destination_waypoint=(opts)
        @destination_waypoint = create_waypoint(
          opts[:destination_waypoint],
          opts[:original_order],
          opts[:current_order]
        )
      end

      private

      def create_waypoint(waypoint, original_order, current_order)
        return if waypoint.blank?
        
        OpenStruct.new(
          latitude: waypoint[0],
          longitude: waypoint[1],
          original_order: original_order,
          current_order: current_order
        )
      end
    end
  end
end
