require 'route_directions/responses/base'
require 'route_directions/errors'
require 'json'

module RouteDirections
  module Responses
    class Osrm < Base
      private

      def process_response
        body = JSON.parse(@http_response.body)
        if body['code'] == 'Ok'
          process_valid(body['routes'][0])
        else
          process_error(body['code'])
        end
      end

      def process_valid(route_body)
        @time = @time + route_body['duration']
        @distance = @distance + route_body['distance']
        @statuses = @statuses + ['OK']
        @polyline = @polyline + [route_body['geometry']]
      end

      def process_status_code(status)
        case status
        when 'NoRoute'
          'NoResultsError'
        when 'InvalidUrl', 'InvalidService', 'InvalidVersion', 'InvalidOptions', 'InvalidQuery', 'InvalidValue', 'NoSegment'
          'InvalidDataError'
        when 'TooBig'
          'OverQueryLimitError'
        else
          status
        end
      end
    end
  end
end
