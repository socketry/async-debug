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

require 'live'

module Async
	module Debug
		class ReactorView < Live::View
			def initialize(id, **data)
				super
				
				@update = nil
				@top = Async::Task.current.reactor
			end
			
			def bind(page)
				super(page)
				
				@update = Async do |task|
					while true
						task.sleep(1.0/10.0)
						self.replace!
					end
				end
			end
			
			def close
				@update.stop
				
				super
			end
			
			def handle(event, details)
				replace!
			end
			
			def render_node(builder, node = @top)
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
