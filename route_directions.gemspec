$:.push File.expand_path('lib', __dir__)

require 'route_directions/version'

Gem::Specification.new do |s|
  s.name        = 'route_directions'
  s.version     = RouteDirections::VERSION
  s.summary     = 'Calculates route directions and stats.'
  s.description = 'Defines a common interface to works over different route calculation providers (Google and OSRM).'
  s.authors     = ['Jose Francisco Caiceo']
  s.files       = Dir['lib/**/*']
  s.license     = 'MIT'

  s.add_dependency('fast-polylines', '~> 1.0.0')
end
