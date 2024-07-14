# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require 'live'

module Async
	module Debug
		class ReactorView < Live::View
			def initialize(...)
				super
				
				@update = nil
				@root = Async::Task.current.root
			end
			
			def bind(page)
				super(page)
				
				@update = Async do |task|
					while true
						task.sleep(1.0/10.0)
						self.update!
					end
				end
			end
			
			def close
				@update.stop
				
				super
			end
			
			def handle(event, details)
				update!
			end
			
			def render_node(builder, node = @root)
				klass = []
				title = []
				
				if node.respond_to?(:status)
					klass << node.status
				end
				
				if node.transient?
					klass << "transient"
				end
				
				if node.respond_to?(:backtrace)
					if backtrace = node.backtrace
						title = backtrace.first(8)
					end
				end
				
				builder.inline :span, class: klass.join(' '), title: title.join("\n") do
					text = node.annotation || "#{node.class} 0x#{node.object_id.to_s(16)}"
					builder.text(text)
				end
				
				if node.children
					builder.tag :ul do
						node.children.each do |child|
							builder.inline :li do
								render_node(builder, child)
							end
						end
					end
				end
			end
			
			def render(builder)
				builder.tag :div, class: 'tree' do
					builder.tag :ul do
						builder.inline :li do
							render_node(builder)
						end
					end
				end
			end
		end
	end
end
