# frozen_string_literal: true

require_relative "lib/async/debug/version"

Gem::Specification.new do |spec|
	spec.name = "async-debug"
	spec.version = Async::Debug::VERSION
	
	spec.summary = "Live debugging for Async."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/async-debug"
	
	spec.metadata = {
		"source_code_uri" => "https://github.com/socketry/async-debug.git",
	}
	
	spec.files = Dir.glob(['{lib,pages,public}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "falcon", "~> 0.42"
	spec.add_dependency "live", "~> 0.5"
	spec.add_dependency "utopia"
end
