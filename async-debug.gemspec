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
	
	spec.files = Dir.glob('{lib,pages,public}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.5.0"
	
	spec.add_dependency "falcon", "~> 0.42.2"
	spec.add_dependency "live", "~> 0.5.0"
	spec.add_dependency "utopia"
	
	spec.add_development_dependency "async-rspec", "~> 1.1"
	spec.add_development_dependency "bake"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered", "~> 0.10"
	spec.add_development_dependency "rspec", "~> 3.6"
end
