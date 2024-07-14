# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

def example
	require 'async'
	require_relative 'lib/async/debug'
	
	Sync do
		debugger = Async::Debug.serve
		
		3.times do
			Async do |task|
				while true
					duration = rand
					task.annotate("Sleeping for #{duration} second...")
					sleep(duration)
				end
			end
		end
	end
end
