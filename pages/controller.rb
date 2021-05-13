
require 'async/websocket/adapters/rack'
require_relative '../lib/async/debug/reactor_view'

prepend Actions

RESOLVER = Live::Resolver.allow(Async::Debug::ReactorView)

on 'live' do |request|
	Console.logger.info("Incoming live connection...")
	
	adapter = Async::WebSocket::Adapters::Rack.open(request.env) do |connection|
		Live::Page.new(RESOLVER).run(connection)
	end
	
	respond?(adapter) or fail!
end

on 'index' do
	@tag = Async::Debug::ReactorView.new('reactor-view')
end
