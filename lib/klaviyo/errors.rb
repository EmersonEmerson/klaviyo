module Klaviyo
  module Errors
    class KlaviyoError < ::StandardError; end
    class NotFound < KlaviyoError; end
    class UnprocessableEntity < KlaviyoError; end
    class InternalServerError < KlaviyoError; end
    class NotAuthorized < KlaviyoError; end
    class AuthenticationError < KlaviyoError; end

    class RequestError < Faraday::Response::Middleware

      def on_complete(env)

        # Ignore any non-error response codes
        return if (status = env[:status]) < 400
        case status
        when 404
          raise Errors::NotFound, env[:body]
        when 422
          raise Errors::UnprocessableEntity, env[:body]
        when 401
          raise Errors::NotAuthorized, env[:body]
        when 407
          # mimic the behavior that we get with proxy requests with HTTPS
          raise Faraday::Error::ConnectionFailed, %{407 "Proxy Authentication Required "}
        else
          raise Errors::InternalServerError, env[:body] # Treat any other errors as 500
        end
      end

    end

  end
end
