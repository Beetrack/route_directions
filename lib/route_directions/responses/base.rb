require 'net/http'

module RouteDirections
  module Responses
    class Base
      DEFAULT_TIME = 20
      DEFAULT_DISTANCE = 100
      ADMISSIBLE = 0.75

      STATUS = %w[ok approached error].freeze
      ERRORS = %w[error_connection
                  no_results_error
                  over_query_limit_error
                  denied_query_error
                  standard_error
                  invalid_data_error].freeze

      attr_reader :distance, :time, :polyline, :status
      attr_reader :http_response

      def initialize(http_response = nil)
        @time = 0
        @distance = 0
        @polyline = []
        @statuses = []
        self.http_response = http_response
      end

      def http_response=(http_response)
        @http_response = http_response
        if http_response && http_response.message == ERRORS[0]
          process_error(ERRORS[0])
        elsif http_response
          process_response
        end
        update_status
      end

      def errors
        @statuses.select { |status| status != STATUS[0] }
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
        @time += DEFAULT_TIME
        @distance += DEFAULT_DISTANCE
        @polyline += ['']
        @statuses += [process_status_code(error)]
      end

      def update_status
        valids = @statuses.select { |status| status == STATUS[0] }.size

        if valids == @statuses.size
          @status = STATUS[0]
        elsif valids >= (ADMISSIBLE * @statuses.size)
          @status = STATUS[1]
        else
          @status = STATUS[2]
        end
      end
    end
  end
end
