require 'route_directions/responses/base'
require 'route_directions/errors'
require 'json'

module RouteDirections
  module Responses
    class Osrm < Base
      OK = 'Ok'

      private

      def process_response
        body = JSON.parse(@http_response.body)
        if body['code'] == OK
          process_valid(body['routes'][0])
        else
          process_error(body['code'])
        end
      end

      def process_valid(route_body)
        @time += route_body['duration']
        @distance += route_body['distance']
        @statuses += [STATUS[0]]
        @polyline += [route_body['geometry']]
      end

      def process_status_code(status)
        case status
        when 'NoRoute'
          ERRORS[1]
        when 'TooBig'
          ERRORS[2]
        when 'InvalidUrl', 'InvalidService', 'InvalidVersion', 'InvalidOptions', 'InvalidQuery', 'InvalidValue', 'NoSegment'
          ERRORS[5]
        else
          status
        end
      end
    end
  end
end
