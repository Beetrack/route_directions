module RouteDirections
  module Responses
    class Base
      DEFAULT_TIME = 20
      DEFAULT_DISTANCE = 100

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

      def process_valid
        raise NotImplementedError, 'Called abstract method process_valid'
      end

      def process_error
        @polyline = (@polyline || []) + ['']
        @time = (@time || 0) + DEFAULT_TIME
        @distance = (@distance || 0) + DEFAULT_DISTANCE
      end
    end
  end
end
