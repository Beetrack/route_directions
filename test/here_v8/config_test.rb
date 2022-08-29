require 'test_helper'
require 'route_directions/clients/here'

module Here
  class ConfigTest < Minitest::Test
    def setup
      RouteDirections.configure(key: 'some api key',
                                provider: 'HereV8')
      @origin = [38.920554, -77.029094]
      @destination = [38.851339, -77.137241]
      @options = {
        waypoints: [
          [38.891494, -77.074785]
        ]
      }
      @here = RouteDirections::Clients::HereV8.new(@origin, @destination, @options)
    end

    def test_provider_url
      assert_equal 'https://router.hereapi.com/v8/routes?via=38.891494,-77.074785', @here.send(:provider_url)
    end

    def test_parameters
      assert_equal (
        {
          origin: '38.920554,-77.029094',
          destination: '38.851339,-77.137241'
        }
      ), @here.send(:parameters, @origin, @destination).slice(:origin, :destination)
    end
  end
end
