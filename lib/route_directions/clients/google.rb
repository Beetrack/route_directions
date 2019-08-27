require 'openssl'
require 'base64'
require 'route_directions/clients/base'
require 'route_directions/responses/google'

module RouteDirections
  module Clients
    class Google < Base
      def response_class
        RouteDirections::Responses::Google
      end

      def max_waypoints
        options[:max_waypoint_size] ||
          Configuration.instance.google_options.max_waypoint_size ||
          MAX_WAYPOINTS
      end

      private

      def request(origin, waypoints, destination)
        Request.new(
          provider_url,
          parameters(origin, waypoints, destination),
          nil,
          max_tries
        )
      end

      def provider_url
        'https://maps.googleapis.com/maps/api/directions/json'
      end

      def parameters(origin, waypoints, destination)
        parameters = {
          origin: origin.join(','),
          destination: destination.join(',')
        }

        if options[:departure_time]
          parameters[:departure_time] = options[:departure_time]
        end

        if waypoints.any?
          parameters[:waypoints] = waypoints.map { |point| point.join(',') }
                                            .join('|')
          parameters[:waypoints].prepend('optimize:true|') if options[:optimize]
        end

        sign(parameters)
      end

      # Signature of the request as documented here:
      # https://developers.google.com/maps/premium/previous-licenses/webservices/auth#digital-signatures
      def sign(parameters)
        parameters.merge!(client_and_channel_by_key)
        path_and_query = "#{URI.parse(provider_url).path}?"\
                         "#{URI.encode_www_form(parameters)}"
        raw_private_key = url_safe_base64_decode(secret_by_key)
        digest = OpenSSL::Digest.new('sha1')
        raw_signature = OpenSSL::HMAC.digest(
          digest, raw_private_key, path_and_query
        )
        parameters[:signature] = url_safe_base64_encode(raw_signature)
        parameters
      end

      def url_safe_base64_decode(base64_string)
        Base64.decode64(base64_string.tr('-_', '+/'))
      end

      def url_safe_base64_encode(raw)
        Base64.encode64(raw).tr('+/', '-_').strip
      end

      def client_and_channel_by_key
        {
          client: key[1],
          channel: key[2]
        }
      end

      def secret_by_key
        key[0]
      end

      def abort?(response)
        ['REQUEST_DENIED'].include? response['status']
      end

      def max_tries
        options[:max_retries] ||
          Configuration.instance.google_options.max_tries
      end

      def key
        options[:key] || Configuration.instance.google_options.key
      end
    end
  end
end
