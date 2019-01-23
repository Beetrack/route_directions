require 'route_directions/responses/base'
require 'route_directions/errors'
require 'json'

module RouteDirections
  module Responses
    class Google < Base
      OK = 'OK'

      private

      def process_response
        body = JSON.parse(@http_response.body)
        if body['status'] == OK
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
        @polyline += [route_body['overview_polyline']['points']]
        @statuses += [STATUS[0]]
      end

      def process_status_code(status)
        case status
        when 'NOT_FOUND', 'ZERO_RESULTS', 'MAX_ROUTE_LENGTH_EXCEEDED', 'MAX_WAYPOINTS_EXCEEDED'
          ERRORS[1]
        when 'OVER_DAILY_LIMIT', 'OVER_QUERY_LIMIT'
          ERRORS[2]
        when 'REQUEST_DENIED', 'INVALID_REQUEST'
          ERRORS[3]
        when 'UNKNOWN_ERROR'
          ERRORS[4]
        else
          status
        end
      end
    end
  end
end
