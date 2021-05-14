# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
