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
          process_error
        end
      end

      def process_valid(route_body)
        @polyline = (@polyline || []) + [route_body['geometry']]
        @time = (@time || 0) + route_body['duration']
        @distance = (@distance || 0) + route_body['distance']
      end
    end
  end
end
