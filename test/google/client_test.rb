require 'test_helper'
require 'route_directions/clients/google'

module Google
  MOCK_DISTANCE = 87_664
  MOCK_TIME = 9_082

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
        key: ['some key', 'gme-client', 'channel'],
        provider: 'Google'
      )

      @origin, @destination, @options = Google.waypoints
      @google = RouteDirections::Clients::Google.new(@origin, @destination, @options)
    end

    def test_correct_distance_calculation
      stub_request_with([Response.waypoints({ splited: false }, :google)]) do
        response = @google.response
        assert_equal Google::MOCK_DISTANCE, response.distance
      end
    end

    def test_correct_time_calculation
      stub_request_with([Response.waypoints({ splited: false }, :google)]) do
        response = @google.response
        assert_equal Google::MOCK_TIME, response.time
      end
    end
  end

  class ClientMultipleRequestTest < Minitest::Test
    def setup
      RouteDirections.configure(
        max_waypoint_size: 3,
        key: ['some key', 'gme-client', 'channel'],
        provider: 'Google'
      )

      @origin, @destination, @options = Google.waypoints
      @google = RouteDirections::Clients::Google.new(@origin, @destination, @options)
    end

    def test_correct_distance_calculation
      responses = [
        Response.waypoints({splited: true, split_count: 0}, :google),
        Response.waypoints({splited: true, split_count: 1}, :google)
      ]
      stub_request_with(responses) do
        response = @google.response
        assert_equal Google::MOCK_DISTANCE, response.distance
      end
    end

    def test_correct_time_calculation
      responses = [
        Response.waypoints({splited: true, split_count: 0}, :google),
        Response.waypoints({splited: true, split_count: 1}, :google)
      ]
      stub_request_with(responses) do
        response = @google.response
        assert_equal Google::MOCK_TIME, response.time
      end
    end
  end
end
