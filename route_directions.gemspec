Gem::Specification.new do |s|
  s.name        = 'route_directions'
  s.version     = '0.0.0'
  s.date        = Date.today.to_s
  s.summary     = 'Calculates route directions and stats.'
  s.description = 'Defines a common interface to works over different route calculation providers (Google and OSRM).'
  s.authors     = ['Jose Francisco Caiceo']
  s.files       = Dir['lib/**/*']
  s.license     = 'MIT'
end
