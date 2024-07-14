# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require 'lively/application'
require_relative 'reactor_view'

module Async
	module Debug
		class Application < Lively::Application
			def self.resolver
				Live::Resolver.allow(ReactorView)
			end
			
			def body(...)
				ReactorView.new(...)
			end
		end
	end
end
