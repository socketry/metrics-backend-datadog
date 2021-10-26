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

require 'metrics'
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

RSpec.describe Metrics do
	it "has a version number" do
		expect(Metrics::VERSION).not_to be nil
	end
	
	context "with mock server" do
		include_context Async::RSpec::Reactor
		
		let(:packets) {Async::Queue.new}
		
		let!(:server_task) do
			Async do
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
		
		after do
			Metrics::Backend::Datadog.close
			server_task.stop
		end
		
		it "can invoke metric wrapper" do
			instance = MyClass.new
			
			instance.my_method(10)
			
			Metrics::Backend::Datadog.flush
			
			expect(packets.dequeue).to eq(
				"my_class.call:1|c|#foo,bar"
			)
		end
		
		it "can send several metrics" do
			instance = MyClass.new
			
			instance.my_method(10)
			instance.my_method(10)
			instance.my_method(10)
			
			Metrics::Backend::Datadog.flush
			
			expect(packets.dequeue).to eq(
				"my_class.call:1|c|#foo,bar\n" \
				"my_class.call:1|c|#foo,bar\n" \
				"my_class.call:1|c|#foo,bar"
			)
		end
	end
end
