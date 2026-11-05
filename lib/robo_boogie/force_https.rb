# frozen_string_literal: true

require "rack/request"

module RoboBoogie
  # Redirects plain-HTTP requests to HTTPS. The owner cookie is Secure, so a page
  # loaded over HTTP couldn't offer editing. Heroku's router terminates TLS and
  # sets X-Forwarded-Proto, which Rack uses for Request#ssl?.
  class ForceHTTPS
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      return @app.call(env) if request.ssl?

      if request.get? || request.head?
        [301, { "location" => request.url.sub(/\Ahttp:/, "https:"), "content-type" => "text/plain" }, []]
      else
        [403, { "content-type" => "text/plain" }, ["HTTPS required"]]
      end
    end
  end
end
