require "socket"
class Server
  def initialize(ip, port)
    @candidates_changed_listeners = []
    @turn_accepted_listeners = []
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:clients] = @clients
    Thread.start do
      run
    end
  end

  def candidates
    @connections[:clients]
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        message = client.gets.chomp
        process_user_message message, {:client => client}
      end
    }
  end

  def listen_user_messages(client )
    Thread.start do
      loop {
        msg = client.gets.chomp
        process_user_message msg
      }
    end
  end

  def process_user_message (message, data = nil)
    json = JSON.parse(message, {:symbolize_names => true})
    case json[:message_type]
      when 'introduce'
        @connections[:clients][json[:player_name]] = data[:client]
        listen_user_messages data[:client]
        notify_candidates_changed
      when 'turn'
        notify_turn_accepted(Dot.new(json[:turn][0], json[:turn][1]))
    end
  end

  def send_new_game (game)
    send_message JSON(game)
  end

  def send_data (dot)
    send_message JSON({:message_type => 'turn', :turn => dot.to_a})
  end

  def send_message (message)
    Thread.start {
      begin
        @connections[:clients].first.last.puts(message)
      rescue Exception => e
        puts e.inspect
      end
    }
  end

  def on_turn_accepted (&block)
    @turn_accepted_listeners << block
  end

  def notify_turn_accepted (dot)
    @turn_accepted_listeners.each{|l| l.call dot}
  end

  def on_candidates_changed (&block)
    @candidates_changed_listeners << block if block
  end

  def notify_candidates_changed
    @candidates_changed_listeners.each{|l| l.call self}
  end
end
 
#Server.new( 3000, "localhost" )