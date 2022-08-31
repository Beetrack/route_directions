require 'test_helper'
require 'route_directions/clients/here'

module Here
  class ConfigTest < Minitest::Test
    def setup
      RouteDirections.configure(key: 'some api key', provider: 'Here')
      @origin = [38.920554, -77.029094]
      @destination = [38.851339, -77.137241]
      @options = {
        waypoints: [
          [38.891494, -77.074785]
        ]
      }
      @here = RouteDirections::Clients::Here.new(@origin, @destination, @options)
    end

    def test_provider_url
      assert_equal 'https://route.ls.hereapi.com/routing/7.2/calculateroute.json',
                  @here.send(:provider_url)
    end

    def test_parameters
      assert_equal (
        {
          waypoint0: 'geo!38.920554,-77.029094',
          waypoint2: 'geo!38.851339,-77.137241',
          waypoint1: 'geo!38.891494,-77.074785'
        }
      ), @here.send(:parameters, @origin, @options[:waypoints], @destination)
              .slice(:waypoint0, :waypoint2, :waypoint1)
    end
  end
end
