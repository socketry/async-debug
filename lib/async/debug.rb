# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "debug/version"

require 'utopia/localization'
require 'falcon/endpoint'
require 'falcon/server'
require 'utopia/setup'

module Async
	module Debug
		# Start the debugger.
		#
		# @parameter endpoint [Async::IO::Endpoint] The endpoint to bind to. Defaults to <https://localhost:9090>.
		def self.serve(endpoint: nil)
			endpoint ||= Falcon::Endpoint.parse("https://localhost:9090")
			builder = Rack::Builder.new
			self.call(builder)
			app = builder.to_app
			middleware = Falcon::Server.middleware(app)
			
			Async(transient: true, annotation: self) do
				Console.logger.info(self, "Live debugger binding to #{endpoint}...")
				Async::HTTP::Server.new(middleware, endpoint).run
			end
		end
		
		# The root directory of the web application files.
		SITE_ROOT = File.expand_path("../..", __dir__)
		
		# The root directory for the utopia middleware.
		PAGES_ROOT = File.expand_path("pages", SITE_ROOT)
		
		# The root directory for static assets.
		PUBLIC_ROOT = File.expand_path("public", SITE_ROOT)
		
		# Appends a project application to the rack builder.
		#
		# @parameter builder [Rack::Builder]
		# @parameter root [String] The file-system root path of the project/gem.
		# @parameter locales [Array(String)] an array of locales to support, e.g. `['en', 'ja']`.
		def self.call(builder, root = Dir.pwd, locales: nil, utopia: Utopia.setup)
			# We want to propate exceptions up when running tests:
			builder.use Rack::ShowExceptions
			
			builder.use Utopia::Static, root: PUBLIC_ROOT
			
			builder.use Utopia::Redirection::Rewrite, {
				'/' => '/index'
			}
			
			builder.use Utopia::Redirection::DirectoryIndex
			
			builder.use Utopia::Redirection::Errors, {
				404 => '/errors/file-not-found'
			}
			
			if locales
				builder.use Utopia::Localization,
					default_locale: locales.first,
					locales: locales
			end
			
			builder.use Utopia::Controller, root: PAGES_ROOT
			builder.use Utopia::Content, root: PAGES_ROOT
			
			builder.run lambda { |env| [404, {}, []] }
		end
	end
end
