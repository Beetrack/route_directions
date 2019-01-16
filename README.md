# Route directions
Defines a common interface to works over different route calculation providers (Google and OSRM).

## Basic Use

```
require 'route_directions'

origin = [-33.406765, -70.57173829999999]
destination = [-33.406765, -70.5814513]

osrm = RouteDirections.query(origin, destination, { provider: 'Osrm' })
google = RouteDirections.query(origin, destination, { key: 'YourKey' })
```
