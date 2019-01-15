require 'route_directions/responses/base'
require 'route_directions/errors'
require 'json'

module RouteDirections
  module Responses
    class Google < Base
      private

      def process_response
        route_body = process_status_code
        # @polyline = route_body['overview_polyline']['points']
        @time = route_body['legs'].reduce(@time || 0) do |sum, value|
          sum + value['duration']['value']
        end
        @distance = route_body['legs'].reduce(@distance || 0) do |sum, value|
          sum + value['distance']['value']
        end
      end

      def process_status_code
        body = JSON.parse(@http_response.body)
        case body['status']
        when 'NOT_FOUND', 'ZERO_RESULTS', 'MAX_ROUTE_LENGTH_EXCEEDED', 'MAX_WAYPOINTS_EXCEEDED'
          raise RouteDirections::NoResultsError, body['status']
        when 'OVER_DAILY_LIMIT', 'OVER_QUERY_LIMIT'
          raise RouteDirections::OverQueryLimitError, body['status']
        when 'REQUEST_DENIED', 'INVALID_REQUEST'
          raise RouteDirections::DeniedQueryError, body['status']
        when 'UNKNOWN_ERROR'
          raise StandardError, body['status']
        else
          return body['routes'][0]
        end
      end
    end
  end
end
