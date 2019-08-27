# Route directions
Defines a common interface to works over different route calculation providers (Google and OSRM).

## Quick Start

### Basic Example
The simplest requests are:
```ruby
require 'route_directions'

origin = [-33.406765, -70.57173829999999]
destination = [-33.406765, -70.5814513]

osrm = RouteDirections.query(origin, destination, { provider: 'Osrm' })
google = RouteDirections.query(origin, destination, { key: ['key', 'client', 'channel'] })
```

### Waypoints
Also, it supports a list of waypoints. It take in consideration the amount of waypoints and makes bunchs of 9 waypoints per request. So, the request won't be double price at google maps service.
```ruby
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
google = RouteDirections.query(origin, destination, { key: ['key', 'client', 'channel'], waypoints: waypoints })
```

## Parameters
Before list the params, We'll define a point like: An array with 2 numbers, the first one `lat` and `lng`. E.g.: `[-33.4208511, -70.5814513]`.

- `origin`: The departure point.
- `destinations`: The arrival point.
- `options`: **[optional]** A hash with the next possible values:
  - `provider`: `Google` or `Osrm` valid options for the moment. **default 'Google'**
  - `waypoints`: An array of points (in the required order).
  - `max_waypoint_size`: The max number of intermediate waypoints (without counting origin and destination) in each request. If the number of `waypoints` is greater than this number, the original route is splited in several requests of size `max_waypoint_size`, and then the results are merged. **default `23`**
  - `max_tries`: The number of tries for each request. `0` or `1` implies only 1 request. **default `3`**
  - `optimize`: A boolean that defines if optimize the provided route by rearranging the waypoints in a more efficient order. If the number of waypoints is greater than the `max_waypoint_size`, the route is splited, so the result probably be suboptimal. Avoid that case if you want to get optimal results. **default `false`**

## Specific parameters by provider
### Google
  - `options`:
    - `key`: **[required]** The auth values for google. It must be an array with the folowing values: `[<private key>, <client ID>, <channel]>`. For more information please visit the following [link](https://developers.google.com/maps/premium/previous-licenses/webservices/auth).
    - `departure_time`: **[optional]** An `Integer`. It specifies the departure time in seconds (*since midnight, January 1, 1970 UTC*).
### OSRM
  - `options`:
    - `host`: **[optional]** In case you're using OSRM you can provide your own server. By default, these requests go to OSRM example.
    - `headers`: **[optional]** A hash with the http headers. In case you use your own server, you may want to specify optional headers to authenticate; for example: `{ Authorization: 'Bearer Bla' }`.

## Response
- `time`: The estimated time to do the path (in seconds).
- `distance`: The traveled distance of the path (in meters).
- `polyline`: An array of the waypoints which draw the route.
- `route_legs`: An array of `RouteLeg` objects that represents the route between two waypoints. There are as many legs as total waypoints - 1. Each has the following parameters:
  - `time`: The time to do the leg (in seconds).
  - `distance`: The distance of the leg (in meters).
  - `polyline`: An array of waypoints which draw the leg (this polyline is more detailed that the overview in the response).
  - `origin_waypoint`: Origin waypoint of the route leg
  - `destination_waypoint`: Destination waypoint of the route leg
  Each waypoint (origin and destination), has the following parameters:
    - `latitude`: The same latitude you send in the parameters.
    - `longitude`: The same longitude you send in the parameters.
    - `original_order`: Order of the input, starting in `0` (`0` is always the `origin`).
    - `current_order`: Resulting order. This value is equal `original_order`, unless you use the `optimize` option.
- `status`: The calculated status based on the historical list of statuses. 3 values:
  - `OK` (all the request were `Ok`s).
  - `Approached` (more than 75% of the requests were `Ok`s).
  - `Error` (less than 75% of the requests were `Ok`s).
- `statuses`: The historical list of the status of each request part of the connection. As a common library, of differnt providers, we have a common list of errors for all the errors of each provider.
  - `OK`: It works.
  - `OverQueryLimitError`: With Google it could be: `'OVER_DAILY_LIMIT', 'OVER_QUERY_LIMIT'`, with Osrm: `'TooBig'`.
  - `NoResultsError`: With Google it could be: `'NOT_FOUND', 'ZERO_RESULTS', 'MAX_ROUTE_LENGTH_EXCEEDED', 'MAX_WAYPOINTS_EXCEEDED'`, with Osrm: `'NoRoute'`.
  - `DeniedQueryError`: With Google it could be: `REQUEST_DENIED`.
  - `InvalidDataError`: With Google it could be: `'INVALID_REQUEST'`, with Osrm: `'InvalidUrl', 'InvalidService', 'InvalidVersion', 'InvalidOptions', 'InvalidQuery', 'InvalidValue', 'NoSegment'`.
  - `ConnectionError`:With Google or Osrm it could be connection errors, basic ruby errors: `SocketError, Errno::ECONNREFUSED, Timeout::Error`.
- `errors`: An array with the errors which happened during the execution of the request. (Possible Values already listed in `statuses`).

## Configuration

For recurring options, you can define a configuration file to set those options in a `Rails` project:
```ruby
# config/initializers/route_directions.rb
RouteDirections.configure(
  provider: 'Google',
  max_waypoint_size: 10,
  key: ['Some key', 'gme-client', 'channel'],
  max_tries: 1
)
```
Then in your code you can simple call the `query` method without that options.

You can also define multiple providers in the same config file (in this case, the default provider remains as `google`):

```ruby
# config/initializers/route_directions.rb
RouteDirections.configure(
  google: {
    key: ['Some key', 'gme-client', 'channel'],
    max_waypoint_size: 10
  },
  osrm: {
    host: 'Some host',
    max_waypoint_size: 50
  }
)
```
Valid options for configuration are:
- `key`
- `host`
- `headers`
- `max_waypoint_size`
- `max_tries`