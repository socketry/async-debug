# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "debug/version"
require_relative "debug/application"

require 'lively/assets'
require 'async/http'
require 'protocol/http/middleware/builder'

module Async
	module Debug
		# Start the debugger.
		#
		# @parameter endpoint [Async::IO::Endpoint] The endpoint to bind to. Defaults to <http://localhost:9090>.
		def self.serve(endpoint: nil)
			endpoint ||= Async::HTTP::Endpoint.parse("http://localhost:9090")
			
			middleware = ::Protocol::HTTP::Middleware.build do |builder|
				builder.use Lively::Assets, root: File.expand_path("../../public", __dir__)
				
				builder.use Lively::Assets
				builder.use Debug::Application
			end
			
			Async(transient: true, annotation: self) do
				Console.logger.info(self, "Live debugger binding to #{endpoint}...")
				Async::HTTP::Server.new(middleware, endpoint).run
			end
		end
	end
end
