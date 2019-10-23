require 'test_helper'
require 'route_directions/clients/google'

class Here::ConfigTest < Minitest::Test
  def setup
    RouteDirections.configure(key: ['some app id', 'some app code'],
                              provider: 'Here')
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
    assert_equal 'https://route.api.here.com/routing/7.2/calculateroute.json',
                 @here.send(:provider_url)
  end

  def test_parameters
    assert_equal (
      {
        origin: '38.920554,-77.029094',
        destination: '38.851339,-77.137241',
        waypoints: '38.891494,-77.074785'
      }
    ), @here.send(:parameters, @origin, @options[:waypoints], @destination)
            .slice(:origin, :destination, :waypoints)
  end
end
