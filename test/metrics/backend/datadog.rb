# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'metrics'

require 'sus/fixtures/async'
require 'async/queue'
require 'async/io/udp_socket'

class MyClass
	def my_method(argument)
	end
end

Metrics::Provider(MyClass) do
	MYCLASS_CALL_COUNT = metric('my_class.call', :counter, description: 'Call counter.')
	
	def my_method(argument)
		MYCLASS_CALL_COUNT.emit(1, tags: ["foo", "bar"])
		
		super
	end
end

describe Metrics do
	it "has a version number" do
		expect(Metrics::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
	
	with "mock server" do
		include Sus::Fixtures::Async::ReactorContext
		
		let(:packets) {Async::Queue.new}
		
		def before
			@server_task = Async do
				server = Async::IO::UDPSocket.new(Socket::AF_INET)
				server.bind("0.0.0.0", 8125)
				
				while true
					packet, address = server.recvfrom(512)
					
					Console.logger.debug(server, packet.inspect)
					packets.enqueue(packet)
				end
			ensure
				server.close
			end
		end
		
		def after
			Metrics::Backend::Datadog.close
			@server_task.stop
			
			super
		end
		
		it "can invoke metric wrapper" do
			instance = MyClass.new
			
			instance.my_method(10)
			
			Metrics::Backend::Datadog.flush
			
			expect(packets.dequeue).to be ==
				"my_class.call:1|c|#foo,bar"
		end
		
		it "can send several metrics" do
			instance = MyClass.new
			
			instance.my_method(10)
			instance.my_method(10)
			instance.my_method(10)
			
			Metrics::Backend::Datadog.flush
			
			expect(packets.dequeue).to be ==
				"my_class.call:1|c|#foo,bar\n" \
				"my_class.call:1|c|#foo,bar\n" \
				"my_class.call:1|c|#foo,bar"
		end
	end
end
