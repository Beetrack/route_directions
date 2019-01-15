require 'minitest/autorun'
require 'route_directions/clients/google'

class GoogleClientTest < Minitest::Test
  def setup
    origin = [38.920554, -77.029094]
    destination = [38.851339, -77.137241]
    options = { waypoints: [
      [38.891494, -77.074785]
    ] }
    @osrm = RouteDirections::Clients::Google.new(origin, destination, options)
  end

  def test_provider_url
    assert_equal 'https://maps.googleapis.com/maps/api/directions/json',
                 @osrm.provider_url
  end

  def test_parameters
    assert_equal (
                   {
                     origin: '38.920554,-77.029094',
                     destination: '38.851339,-77.137241',
                     waypoints: '38.891494,-77.074785',
                     key: nil
                   }
                 ),
                 @osrm.parameters
  end
end
