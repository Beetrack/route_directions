require 'route_directions/responses/base'
require 'route_directions/errors'
require 'json'

module RouteDirections
  module Responses
    class Osrm < Base
      private

      def process_response
        route_body= process_status_code
        @distance = route_body['distance']
        @time = route_body['duration']
        @polyline = route_body['geometry']
      end

      def process_status_code
        body = JSON.parse(@http_response.body)
        case body['code']
        when 'NoRoute'
          raise RouteDirections::NoResultsError, body['status']
        when 'InvalidUrl', 'InvalidService', 'InvalidVersion', 'InvalidOptions', 'InvalidQuery', 'InvalidValue', 'NoSegment'
          raise RouteDirections::InvalidDataError, body['status']
        when 'TooBig'
          raise RouteDirections::OverQueryLimitError, body['status']
        when 'Ok'
          return body['routes'][0]
        end
      end
    end
  end
end
