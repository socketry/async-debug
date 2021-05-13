
require "async"
require "async/clock"
require "protocol/http/middleware"
require "async/http"

class Google < Protocol::HTTP::Middleware
	def search(term)
		Console.logger.info(self) {"Searching for #{term}..."}
		
		self.get("/search?q=#{term}", {"user-agent" => "Hi Google!"})
	end
end

def default
	require 'async'
	require_relative 'lib/async/debug'
	
	url = "https://www.google.com/search"
	endpoint = Async::HTTP::Endpoint.parse(url)
	
	terms = %w{thoughtful fear size payment lethal modern recognise face morning sulky mountainous contain science snow uncle skirt truthful door travel snails closed rotten halting creator teeny-tiny beautiful cherries unruly level follow strip team things suggest pretty warm end cannon bad pig consider airport strengthen youthful fog three walk furry pickle moaning fax book ruddy sigh plate cakes shame stem faulty bushes dislike train sleet one colour behavior bitter suit count loutish squeak learn watery orange idiotic seat wholesale omniscient nostalgic arithmetic instruct committee puffy program cream cake whistle rely encourage war flagrant amusing fluffy prick utter wacky occur daily son check}
	
	Async do |task|
		debugger = Async::Debug.serve
		
		client = Async::HTTP::Client.new(endpoint)
		google = Google.new(client)
		
		semaphore = Async::Semaphore.new(8)
		
		results = terms.map do |term|
			semaphore.async do |task|
				task.annotate("Fetching #{term}...")
				response = google.search(term)
				[term, response.read.scan(term).count]
			end
		end.map(&:wait)
		
		pp results
	end
end
