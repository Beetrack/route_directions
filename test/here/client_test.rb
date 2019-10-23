require 'test_helper'
require 'route_directions/clients/here'

module Here
  MOCK_DISTANCE = 81_880
  MOCK_TIME = 8_065

  MOCK_OPTIMIZED_DISTANCE = 44_087
  MOCK_OPTIMIZED_TIME = 6_391

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
        key: ['some app id', 'some app code'],
        provider: 'Here'
      )

      @origin, @destination, @options = Here.waypoints
      @here = RouteDirections::Clients::Here.new(@origin, @destination, @options)
    end

    def test_correct_distance_calculation
      stub_request_with([Response.waypoints({ splited: false }, :here)]) do
        response = @here.response
        assert_equal Here::MOCK_DISTANCE, response.distance
      end
    end

    def test_correct_time_calculation
      stub_request_with([Response.waypoints({ splited: false }, :here)]) do
        response = @here.response
        assert_equal Here::MOCK_TIME, response.time
      end
    end
  end

  class ClientOptimizeSingleRequestTest < Minitest::Test
    def setup
      RouteDirections.configure(
        max_waypoint_size: 7,
        key: ['some app id', 'some app code'],
        provider: 'Here'
      )

      @origin, @destination, @options = Here.waypoints
      @options[:optimize] = true
      @here = RouteDirections::Clients::Here.new(@origin, @destination, @options)
    end

    def test_correct_distance_calculation
      stub_request_with([Response.waypoints({ splited: false, optimized: true }, :here)]) do
        response = @here.response
        assert_equal Here::MOCK_OPTIMIZED_DISTANCE, response.distance
      end
    end

    def test_correct_time_calculation
      stub_request_with([Response.waypoints({ splited: false, optimized: true }, :here)]) do
        response = @here.response
        assert_equal Here::MOCK_OPTIMIZED_TIME, response.time
      end
    end

    def test_correct_order
      stub_request_with([Response.waypoints({ splited: false, optimized: true }, :here)]) do
        response = @here.response
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
        key: ['some app id', 'some app code'],
        provider: 'Here'
      )

      @origin, @destination, @options = Here.waypoints
      @here = RouteDirections::Clients::Here.new(@origin, @destination, @options)
    end

    def test_correct_distance_calculation
      responses = [
        Response.waypoints({splited: true, split_count: 0}, :here),
        Response.waypoints({splited: true, split_count: 1}, :here)
      ]
      stub_request_with(responses) do
        response = @here.response
        assert_equal Here::MOCK_DISTANCE, response.distance
      end
    end

    def test_correct_time_calculation
      responses = [
        Response.waypoints({splited: true, split_count: 0}, :here),
        Response.waypoints({splited: true, split_count: 1}, :here)
      ]
      stub_request_with(responses) do
        response = @here.response
        assert_equal Here::MOCK_TIME, response.time
      end
    end
  end

  class ClientOptimizeMultipleRequestTest < Minitest::Test
    def setup
      RouteDirections.configure(
        max_waypoint_size: 3,
        key: ['some app id', 'some app code'],
        provider: 'Here'
      )

      @origin, @destination, = Here.waypoints
      @options = { waypoints: [
        [-33.38713, -70.65869], [-33.48292, -70.69633],
        [-33.49337, -70.67625], [-33.5031, -70.6553],
        [-33.50138, -70.63951], [-33.4748, -70.61438],
        [-33.50081, -70.61685]
      ], optimize: true }
      @here = RouteDirections::Clients::Here.new(@origin, @destination, @options)
    end

    def test_correct_distance_calculation
      responses = [
        Response.waypoints({splited: true, split_count: 0, optimized: true }, :here),
        Response.waypoints({splited: true, split_count: 1, optimized: true }, :here)
      ]
      stub_request_with(responses) do
        response = @here.response
        assert_equal Here::MOCK_OPTIMIZED_DISTANCE, response.distance
      end
    end

    def test_correct_time_calculation
      responses = [
        Response.waypoints({splited: true, split_count: 0, optimized: true }, :here),
        Response.waypoints({splited: true, split_count: 1, optimized: true }, :here)
      ]
      stub_request_with(responses) do
        response = @here.response
        assert_equal Here::MOCK_OPTIMIZED_TIME, response.time
      end
    end

    def test_correct_order
      responses = [
        Response.waypoints({splited: true, split_count: 0, optimized: true }, :here),
        Response.waypoints({splited: true, split_count: 1, optimized: true }, :here)
      ]
      stub_request_with(responses) do
        response = @here.response
        order_array = response.route_legs.map do |leg|
          leg.origin_waypoint.original_order
        end
        assert_equal [0, 1, 2, 3, 4, 5, 7, 6], order_array
      end
    end
  end
end
