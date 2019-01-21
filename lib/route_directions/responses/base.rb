require 'net/http'

module RouteDirections
  module Responses
    class Base
      DEFAULT_TIME = 20
      DEFAULT_DISTANCE = 100
      ADMISSIBLE = 0.75

      attr_reader :distance, :time, :polyline, :status
      attr_reader :http_response

      def initialize(http_response = nil)
        @statuses = []
        self.http_response = http_response
      end

      def http_response=(http_response)
        @http_response = http_response
        if http_response && http_response.message == 'ErrorConnection'
          process_error('ErrorConnection')
        elsif http_response
          process_response
        end
        update_status
      end

      def errors
        @statuses.select { |status| status != 'OK' }
      end

      private

      def process_response
        raise NotImplementedError, 'Called abstract method process_response'
      end

      def process_valid
        raise NotImplementedError, 'Called abstract method process_valid'
      end

      def process_status_code
        raise NotImplementedError, 'Called abstract method process_status_code'
      end

      def process_error(error)
        @polyline = (@polyline || []) + ['']
        @time = (@time || 0) + DEFAULT_TIME
        @distance = (@distance || 0) + DEFAULT_DISTANCE
        @statuses = (@statuses || []) + [process_status_code(error)]
      end

      def update_status
        valids = @statuses.select { |status| status == 'OK' }.size

        if valids == @statuses.size
          @status = 'OK'
        elsif valids >= (ADMISSIBLE * @statuses.size)
          @status = 'Approached'
        else
          @status = 'Error'
        end
      end
    end
  end
end
