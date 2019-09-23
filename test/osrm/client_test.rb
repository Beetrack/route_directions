require 'test_helper'
require 'route_directions/clients/osrm'

module Osrm
  MOCK_DISTANCE = 71_838.3
  MOCK_TIME = 4_925.2

  MOCK_OPTIMIZED_DISTANCE = 43_150.2
  MOCK_OPTIMIZED_TIME = 3_095.5

  def self.waypoints
    origin = [-33.43212, -70.59446]
    destination = [-33.46478, -70.62882]
    options = { waypoints: [
      [-33.50138, -70.63951], [-33.4748, -70.61438],
      [-33.5031, -70.6553], [-33.49337, -70.67625],
      [-33.50081, -70.61685], [-33.48292, -70.69633],
      [-33.38713, -70.65869]
    ] }
    [origin, destination, options]
  end

  class ClientSingleRequestTest < Minitest::Test
    def setup
      RouteDirections.configure(
        max_waypoint_size: 7,
        provider: 'Osrm'
      )

      @origin, @destination, @options = Osrm.waypoints
      @osrm = RouteDirections::Clients::Osrm.new(@origin, @destination, @options)
    end

    def test_correct_distance_calculation
      stub_request_with([Response.waypoints({ splited: false }, :osrm)]) do
        response = @osrm.response
        assert_in_delta Osrm::MOCK_DISTANCE, response.distance
      end
    end

    def test_correct_time_calculation
      stub_request_with([Response.waypoints({ splited: false }, :osrm)]) do
        response = @osrm.response
        assert_in_delta Osrm::MOCK_TIME, response.time
      end
    end
  end

  class ClientOptimizeSingleRequestTest < Minitest::Test
    def setup
      RouteDirections.configure(
        max_waypoint_size: 7,
        provider: 'Osrm'
      )

      @origin, @destination, @options = Osrm.waypoints
      @options[:optimize] = true
      @osrm = RouteDirections::Clients::Osrm.new(@origin, @destination, @options)
    end

    def test_correct_distance_calculation
      stub_request_with([Response.waypoints({ splited: false, optimized: true }, :osrm)]) do
        response = @osrm.response
        assert_equal Osrm::MOCK_OPTIMIZED_DISTANCE, response.distance
      end
    end

    def test_correct_time_calculation
      stub_request_with([Response.waypoints({ splited: false, optimized: true }, :osrm)]) do
        response = @osrm.response
        assert_equal Osrm::MOCK_OPTIMIZED_TIME, response.time
      end
    end

    def test_correct_order
      stub_request_with([Response.waypoints({ splited: false, optimized: true }, :osrm)]) do
        response = @osrm.response
        order_array = response.route_legs.map do |leg|
          leg.origin_waypoint.original_order
        end
        assert_equal [0, 7, 6, 4, 3, 1, 5, 2], order_array
      end
    end
  end

  class ClientMultipleRequestTest < Minitest::Test
    def setup
      RouteDirections.configure(
        max_waypoint_size: 3,
        provider: 'Osrm'
      )

      @origin, @destination, @options = Osrm.waypoints
      @osrm = RouteDirections::Clients::Osrm.new(@origin, @destination, @options)
    end

    def test_correct_distance_calculation
      responses = [
        Response.waypoints({ splited: true, split_count: 0 }, :osrm),
        Response.waypoints({ splited: true, split_count: 1 }, :osrm)
      ]
      stub_request_with(responses) do
        response = @osrm.response
        assert_in_delta Osrm::MOCK_DISTANCE, response.distance
      end
    end

    def test_correct_time_calculation
      responses = [
        Response.waypoints({ splited: true, split_count: 0 }, :osrm),
        Response.waypoints({ splited: true, split_count: 1 }, :osrm)
      ]
      stub_request_with(responses) do
        response = @osrm.response
        assert_in_delta Osrm::MOCK_TIME, response.time
      end
    end
  end
end
