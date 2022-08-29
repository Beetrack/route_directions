require 'test_helper'
require 'route_directions/clients/v8/here'

module Here
  module V8
    MOCK_DISTANCE = 74_117
    MOCK_TIME = 8_579

    def self.waypoints
      origin = [-33.43212, -70.59446]
      destination = [-33.46478, -70.62882]
      options = {
        waypoints: [
          [-33.50138, -70.63951], [-33.4748, -70.61438],
          [-33.5031, -70.6553], [-33.49337, -70.67625],
          [-33.50081, -70.61685], [-33.48292, -70.69633],
          [-33.38713, -70.65869]
        ],
        departure_time: Time.now.to_i
      }
      [origin, destination, options]
    end

    class ClientSingleRequestTest < Minitest::Test
      def setup
        RouteDirections.configure(
          max_waypoint_size: 7,
          key: 'some api key',
          provider: 'Here'
        )

        @origin, @destination, @options = Here::V8.waypoints
        @here = RouteDirections::Clients::V8::Here.new(@origin, @destination, @options)
      end

      def test_correct_distance_calculation
        stub_request_with([Response.waypoints({ splited: false }, :here_v8)]) do
          response = @here.response
          assert_equal Here::V8::MOCK_DISTANCE, response.distance
        end
      end

      def test_correct_time_calculation
        stub_request_with([Response.waypoints({ splited: false }, :here_v8)]) do
          response = @here.response
          assert_equal Here::V8::MOCK_TIME, response.time
        end
      end
    end

    class ClientMultipleRequestTest < Minitest::Test
      def setup
        RouteDirections.configure(
          max_waypoint_size: 3,
          key: 'some api key',
          provider: 'Here'
        )

        @origin, @destination, @options = Here::V8.waypoints
        @here = RouteDirections::Clients::V8::Here.new(@origin, @destination, @options)
      end

      def test_correct_distance_calculation
        responses = [
          Response.waypoints({splited: true, split_count: 0}, :here_v8),
          Response.waypoints({splited: true, split_count: 1}, :here_v8)
        ]
        stub_request_with(responses) do
          response = @here.response
          assert_equal Here::V8::MOCK_DISTANCE, response.distance
        end
      end

      def test_correct_time_calculation
        responses = [
          Response.waypoints({splited: true, split_count: 0}, :here_v8),
          Response.waypoints({splited: true, split_count: 1}, :here_v8)
        ]
        stub_request_with(responses) do
          response = @here.response
          assert_equal Here::V8::MOCK_TIME, response.time
        end
      end
    end
  end
end
