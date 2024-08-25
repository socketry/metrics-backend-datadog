# frozen_string_literal: true

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
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/metrics-backend-datadog/",
		"source_code_uri" => "https://github.com/socketry/metrics-backend-datadog.git",
	}
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "dogstatsd-ruby", "~> 5.0"
	spec.add_dependency "metrics"
end
