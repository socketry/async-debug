# Getting Started

This guide explains how to use `async-debug` for assisting with the development of concurrent systems.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add async-debug
~~~

## Attaching the Debugger

You need to add {ruby Async::Debug.serve} to your event loop.

~~~ ruby
require 'async'
require 'async/debug'

Async do |task|
	Async::Debug.serve
	
	task.sleep(1000)
end
~~~

In the console you will see a message like:

~~~
0.93s     info: Async::Debug [ec=0xb784] [pid=760041] [2021-05-14 13:35:46 +1200]
							| Binding to #<Falcon::Endpoint https://localhost:9090/ {}>...
~~~

Open that URL to access the debugger.
