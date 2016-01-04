require 'socket'

Thread.start do
  begin
    u1 = UDPSocket.new
	  u1.bind(Socket::INADDR_ANY, 80)

    puts 'u1 bound'
    data = u1.recv(1000)
    puts 'u1 received: ' + data
  rescue Exception => ex
    puts ex.inspect
  end

end
sleep 3
#t1.join

u3 = UDPSocket.new
u3.connect('255.255.255.255', 80)
sent = u3.send ['Hello, fuckers'].pack('a'), 0
puts "bytes sent #{sent}"
gets
