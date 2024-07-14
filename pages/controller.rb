# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require 'async/websocket/adapters/rack'
require_relative '../lib/async/debug/reactor_view'

prepend Actions

RESOLVER = Live::Resolver.allow(Async::Debug::ReactorView)

on 'live' do |request|
	adapter = Async::WebSocket::Adapters::Rack.open(request.env) do |connection|
		Live::Page.new(RESOLVER).run(connection)
	end
	
	respond?(adapter) or fail!
end

on 'index' do
	@tag = Async::Debug::ReactorView.new('reactor-view')
end
