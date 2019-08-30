require 'route_directions/configuration'

class ConfigurationTest < Minitest::Test
  def test_single_provider
    RouteDirections.configure({
      max_waypoint_size: 23,
      provider: 'Google'
    })
    assert_equal 23,
                 RouteDirections::Configuration.instance.google_options.max_waypoint_size
    assert_equal 'Google',
                 RouteDirections::Configuration.instance.default_provider
  end

  def test_invalid_provider
    assert_raises ArgumentError do
      RouteDirections.configure(
        max_waypoint_size: 23,
        provider: 'some_provider'
      )
    end
  end

  def test_multiple_providers
    RouteDirections.configure(
      google: {
        key: 'some_key'
      },
      osrm: {
        host: 'some_host'
      }
    )
    assert_equal 'some_key',
                 RouteDirections::Configuration.instance.google_options.key
    assert_equal 'some_host',
                 RouteDirections::Configuration.instance.osrm_options.host
  end

  def test_multiple_providers_with_shared_data
    RouteDirections.configure(
      max_waypoint_size: 23,
      google: {
        key: 'some_key'
      },
      osrm: {
        host: 'some_host'
      }
    )
    assert_equal 23,
                 RouteDirections::Configuration.instance.google_options.max_waypoint_size
    assert_equal 23,
                 RouteDirections::Configuration.instance.osrm_options.max_waypoint_size
  end
end
