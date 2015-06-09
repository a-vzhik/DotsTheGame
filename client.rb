require "socket"
class Client
  attr_reader :server
  def initialize( server )
    @turn_accepted_listeners = []
    @new_game_listeners = []
    @server = server
    @request = nil
    @response = nil
    listen
    #send
    #@request.join
    #@response.join
  end
 
  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        json = JSON.parse(msg, {:symbolize_names => true})

        case json[:message_type]
          when 'new_game'
            notify_new_game (json[:game])
          when 'turn'
            notify_turn_accepted  (Dot.new(json[:turn][0], json[:turn][1]))
        end
      }
    end
  end

  def send_introduce_message (name)
    send_message JSON({:message_type => 'introduce', :player_name => name})
  end

  def send_data (dot)
    send_message JSON({:message_type => 'turn', :turn => dot.to_a})
  end

  def send_message (message)
    Thread.start {
      begin
        @server.puts(message)
      rescue Exception => e
        puts e.inspect
      end
    }
  end

  def on_turn_accepted (&block)
    @turn_accepted_listeners << block if block
  end

  def notify_turn_accepted (dot)
    @turn_accepted_listeners.each{|l| l.call dot}
  end

  def on_new_game (&block)
    @new_game_listeners << block if block
  end

  def notify_new_game (game)
    @new_game_listeners.each{|l| l.call game}
  end

  private :send_message, :notify_turn_accepted, :notify_new_game
end
