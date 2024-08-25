# Metrics::Backend::Datadog

A metrics backend for Datadog.

[![Development Status](https://github.com/socketry/metrics-backend-datadog/workflows/Test/badge.svg)](https://github.com/socketry/metrics-backend-datadog/actions?workflow=Test)

## Usage

If you need to specify custom options, you can override the default statsd client instance.

``` ruby
# config/initializers/metrics/backend/datadog.rb

require 'metrics/backend/datadog'

module Metrics
	module Backend
		module Datadog
			# Override the default instance setup:
			def self.new
				instance = ::Datadog::Statsd.new('localhost', 8125, logger: Console.logger)
				
				at_exit do
					self.close
				end
				
				return instance
			end
		end
	end
end
```

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.

## See Also

  - [metrics](https://github.com/socketry/metrics) — Capture metrics about code execution in a vendor agnostic way.
