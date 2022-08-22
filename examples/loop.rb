#!/usr/bin/env ruby

require 'async'
require_relative '../lib/async/debug'

Async do
	Async::Debug.serve
	
	Async do |task|
		i = 0
		while true
			task.annotate("Loop Iteration #{i}")
			task.sleep 0.1
			i += 1
		end
	end
end
