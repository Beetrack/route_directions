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
Before list the params, We'll define a point like: An array with 2 numbers, the first one `lat` and `lng`. E.g.: `[-33.4208511, -70.5814513]`.

- `origin`: The departure point.
- `destinations`: The arrival point.
- `options`: **[optional]** A hash with the next possible values:
  - `provider`: `Google` or `Osrm` valid options for the moment **'Google' by default**.
  - `waypoints`: An array of points (in the required order).
  - `key`: The google api key. **REQUIRED for google**.
  - `host`: In case you're using OSRM you can provide your own server. By default, these requests go to OSRM example.

## Response
- `time`: The stimated time to do the path (in seconds).
- `distance`: The traveled distance of the path (in meters).
- `polyline`: An array of the polylines (string encoded) which draw the route.
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
