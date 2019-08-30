require 'test_helper'
require 'route_directions/clients/google'

class Google::ConfigTest < Minitest::Test
  def setup
    RouteDirections.configure(key: ['some key', 'gme-client', 'channel'],
                              provider: 'Google')
    @origin = [38.920554, -77.029094]
    @destination = [38.851339, -77.137241]
    @options = {
      waypoints: [
        [38.891494, -77.074785]
      ]
    }
    @google = RouteDirections::Clients::Google.new(@origin, @destination, @options)
  end

  def test_provider_url
    assert_equal 'https://maps.googleapis.com/maps/api/directions/json',
                 @google.send(:provider_url)
  end

  def test_parameters
    assert_equal (
      {
        origin: '38.920554,-77.029094',
        destination: '38.851339,-77.137241',
        waypoints: '38.891494,-77.074785'
      }
    ), @google.send(:parameters, @origin, @options[:waypoints], @destination)
              .slice(:origin, :destination, :waypoints)
  end

  def test_signature
    assert_equal (
      {
        client: 'gme-client',
        channel: 'channel',
        signature: 'h6fYr8ZXIUfOtfSbSbfu4n4uh00='
      }), @google.send(:parameters, @origin, @options[:waypoints], @destination)
                 .slice(:client, :channel, :signature)
  end
end
