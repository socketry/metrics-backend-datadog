# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'metrics'

require 'sus/fixtures/async'
require 'async/queue'

class MyClass
	def my_method(argument)
	end
end

Metrics::Provider(MyClass) do
	MYCLASS_CALL_COUNT = Metrics.metric('my_class.call', :counter, description: 'Call counter.')
	MYCLASS_CALL_DISTRIBUTION = Metrics.metric('my_class.call', :distribution, description: 'Call distribution.')
	
	def my_method(argument)
		MYCLASS_CALL_COUNT.emit(1, tags: ["foo", "bar"])
		
		super
	end
end

describe Metrics do
	it "has a version number" do
		expect(Metrics::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
	
	it "supports distributions" do
		expect(MYCLASS_CALL_DISTRIBUTION).to be_a(Metrics::Backend::Datadog::Distribution)
	end
	
	with "mock server" do
		include Sus::Fixtures::Async::ReactorContext
		
		let(:host) {"127.0.0.1"}
		let(:port) {8125}
		
		let(:packets) {Async::Queue.new}
		
		before do
			family = Addrinfo.udp(host, port).afamily
			server = UDPSocket.new(family)
			server.bind(host, port)
			
			@server_task = Async do
				while true
					packet, address = server.recvfrom(512)
					
					Console.debug(server, packet.inspect)
					packets.enqueue(packet)
				end
			ensure
				server.close
			end
		end
		
		after do
			Metrics::Backend::Datadog.close
			if @server_task
				@server_task.stop
				@server_task = nil
			end
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
