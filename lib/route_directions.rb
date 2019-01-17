require 'route_directions/query'
require 'route_directions/configuration'

module RouteDirections
  def self.query(origin, destination, options = {})
    query = Query.new(origin, destination, options)
    query.execute
  end
end
