# Route directions
Defines a common interface to works over different route calculation providers (Google and OSRM).

## Quick Start

### Basic Example
The simplest requests are:
```
require 'route_directions'

origin = [-33.406765, -70.57173829999999]
destination = [-33.406765, -70.5814513]

osrm = RouteDirections.query(origin, destination, { provider: 'Osrm' })
google = RouteDirections.query(origin, destination, { key: 'YourKey' })
```

### Waypoints
Also, it supports a list of waypoints. It take in consideration the amount of waypoints and makes bunchs of 9 waypoints per request. So, the request won't be double price at google maps service.
```
require 'route_directions'

origin = [-33.406765, -70.57173829999999]
destination = [-33.406765, -70.57173829999999]

waypoints = [
  [-33.4208511, -70.5814513],
  [-33.4528005, -70.65591239999999],
  [-33.4568062, -70.618264],
  [-33.4565644, -70.7071033],
  [-33.4388811, -70.638814]
]

osrm = RouteDirections.query(origin, destination, { provider: 'Osrm', waypoints: waypoints })
google = RouteDirections.query(origin, destination, { key: 'YourKey', waypoints: waypoints })
```

## Params
Before list the params, We'll define a point like: An array with 2 numbers, the first one `lat` and `lng`. E.g.: `[-33.4208511, -70.5814513]`

### Required
- `origin`: The departure point
- `destinations`: The arrival point
- `options`: A hash

### At Options
- `provider`: `Google` or `Osrm` valid options for the moment.
- `waypoints`: An array of points (in the required order)
- `key`: The google api key. **REQUIRED: for google**
- `host`: In case you're using OSRM you can provide your own server. By default, these requests go to OSRM example.
