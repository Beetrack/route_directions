module RouteDirections
  module Responses
    class Base
      attr_reader :distance, :time, :polyline

      def initialize(http_response)
        @http_response = http_response
        process_response
      end

      private

      def process_response
        raise NotImplementedError, 'Called abstract method process_response'
      end
    end
  end
end
