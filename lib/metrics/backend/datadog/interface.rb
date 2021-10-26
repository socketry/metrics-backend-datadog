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

require 'datadog/statsd'

require 'metrics/metric'
require 'metrics/tags'

require 'console'

module Metrics
	module Backend
		module Datadog
			def self.new
				instance = ::Datadog::Statsd.new('localhost', 8125, logger: Console.logger)
				
				at_exit do
					self.close
				end
				
				return instance
			end
			
			def self.flush
				@instance&.flush
			end
			
			def self.close
				@instance&.close
				@instance = nil
			end
			
			def self.instance
				@instance ||= self.new
			end
			
			class Metric < Metrics::Metric
				def emit(value, tags: nil, sample_rate: 1.0)
					Datadog.instance.count(@name, value, sample_rate: sample_rate, tags: Tags.normalize(tags))
				end
			end
			
			# Absolute value measurement.
			class Gauge < Metric
				def emit(value, tags: nil, sample_rate: 1.0)
					Datadog.instance.gauge(@name, value, sample_rate: sample_rate, tags: Tags.normalize(tags))
				end
			end
			
			class Histogram < Metric
				def emit(value, tags: nil, sample_rate: 1.0)
					Datadog.instance.histogram(@name, value, sample_rate: sample_rate, tags: Tags.normalize(tags))
				end
			end
			
			class Distribution < Metric
				def emit(value, tags: nil, sample_rate: 1.0)
					Datadog.instance.distribution(@name, value, sample_rate: sample_rate, tags: Tags.normalize(tags))
				end
			end
			
			module Interface
				def metric(name, type, description: nil, unit: nil)
					klass = Metric
					
					case name
					when :counter
						# klass = Metric
					when :guage
						klass = Gauge
					when :histogram
						klass = Histogram
					when :distribution
						klass = Distribution
					end
					
					klass.new(name, type, description, unit)
				end
			end
		end
		
		Interface = Datadog::Interface
	end
end
