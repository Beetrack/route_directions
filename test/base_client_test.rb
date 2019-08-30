require 'minitest/autorun'
require 'route_directions/clients/base'

module BaseClientTest
  class ValidInputTest < Minitest::Test
    def setup
      @origin = [38.920554, -77.029094]
      @destination = [38.851339, -77.137241]
      @options = { waypoints: [
        [38.891494, -77.074785]
      ] }
    end

    def test_validate_origin
      assert_equal @origin,
                   RouteDirections::Clients::Base.new(
                     @origin,
                     @destination,
                     @options
                   ).origin
    end

    def test_validate_destination
      assert_equal @destination,
                   RouteDirections::Clients::Base.new(
                     @origin,
                     @destination,
                     @options
                   ).destination
    end
  end

  class EmptyInputTest < Minitest::Test
    def setup
      @origin = nil
      @destination = nil
      @options = {}
    end

    def test_validate_inputs
      assert_raises ArgumentError do
        RouteDirections::Clients::Base.new(
          @origin,
          @destination,
          @options
        )
      end
    end
  end

  class InvalidInputTest < Minitest::Test
    def setup
      @origin = [138.920554, -77.029094]
      @destination = [38.851339, -277.137241]
      @options = {}
    end

    def test_validate_inputs
      assert_raises ArgumentError do
        RouteDirections::Clients::Base.new(
          @origin,
          @destination,
          @options
        )
      end
    end
  end
end
