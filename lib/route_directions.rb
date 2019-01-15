require 'route_directions/query'

module RouteDirections
  def self.query(origin, destination, options = {})
    query = Query.new(origin, destination, options)
    query.execute
  end
end
