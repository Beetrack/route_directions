require 'route_directions/responses/base'
require 'route_directions/errors'
require 'json'

module RouteDirections
  module Responses
    class Google < Base
      private

      def process_response
        body = JSON.parse(@http_response.body)
        if body['status'] == 'OK'
          process_valid(body['routes'][0])
        else
          process_error(body['status'])
        end
      end

      def process_valid(route_body)
        @polyline = (@polyline || []) + [route_body['overview_polyline']['points']]
        @time = route_body['legs'].reduce(@time || 0) do |sum, value|
          sum + value['duration']['value']
        end
        @distance = route_body['legs'].reduce(@distance || 0) do |sum, value|
          sum + value['distance']['value']
        end
        @statuses = (@statuses || []) + ['OK']
      end
    end
  end
end
