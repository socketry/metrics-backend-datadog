
require_relative "lib/metrics/backend/datadog/version"

Gem::Specification.new do |spec|
	spec.name = "metrics-backend-datadog"
	spec.version = Metrics::Backend::Datadog::VERSION
	
	spec.summary = "Application metrics and instrumentation."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/metrics-backend-datadog"
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_dependency "dogstatsd-ruby", "~> 5.0"
	spec.add_dependency "metrics"
	
	spec.add_development_dependency "rspec", "~> 3.0"
end
