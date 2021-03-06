require 'minitest/autorun'
require 'route_directions/clients/osrm'

module Osrm
  class ConfigTest < Minitest::Test
    def setup
      @origin = [38.920554, -77.029094]
      @destination = [38.851339, -77.137241]
      @options = { waypoints: [
        [38.891494, -77.074785]
      ] }
      @osrm = RouteDirections::Clients::Osrm.new(@origin, @destination, @options)
    end

    def test_base_url
      assert_equal 'https://router.project-osrm.org/route/v1/driving/',
                   @osrm.send(:base_url)
    end

    def test_provider_url
      assert_equal 'https://router.project-osrm.org/route/v1/driving/' \
                   '-77.029094,38.920554;-77.074785,38.891494;' \
                   '-77.137241,38.851339',
                   @osrm.send(:provider_url, @origin, @options[:waypoints], @destination)
    end

    def test_parameters
      assert_equal ({ steps: true }),
                   @osrm.send(:parameters)
    end
  end
end
