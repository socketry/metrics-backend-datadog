# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'datadog/statsd'

require 'metrics/metric'
require 'metrics/tags'

require 'console'

module Metrics
	module Backend
		module Datadog
			def self.new
				instance = ::Datadog::Statsd.new('127.0.0.1', 8125, logger: Console.logger)
				
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
