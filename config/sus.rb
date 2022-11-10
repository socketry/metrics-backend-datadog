# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

ENV['METRICS_BACKEND'] ||= 'metrics/backend/datadog'

require 'covered/sus'
include Covered::Sus
