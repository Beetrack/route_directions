module RouteDirections
  module Responses
    class Base
      attr_reader :distance, :time, :polyline
      attr_reader :http_response

      def initialize(http_response = nil)
        self.http_response = http_response
      end

      def http_response=(http_response)
        @http_response = http_response
        process_response if http_response
      end

      private

      def process_response
        raise NotImplementedError, 'Called abstract method process_response'
      end
    end
  end
end
