class LocalNetworkGameStartModel
  attr_accessor :server_ip, :server_port, :client_ip, :client_port, :player_name

  attr_reader :message, :network_interfaces, :is_waiting

  def initialize
    @message_changed_listeners = []

    settings = load

    @player_name = settings[:player_name]

    @network_interfaces = Socket.ip_address_list
      .select { |i| i.ipv4? }
      .map { |i| i.ip_address }

    @server_ip = @network_interfaces.find { |i| i == settings[:server_ip] }
    @server_ip = @network_interfaces.first if @server_ip == nil
    @server_port = settings[:server_port]

    @client_ip = settings[:client_ip]
    @client_port = settings[:client_port]
  end

  def message=(msg)
    @message = msg
    raise_message_changed
  end

  def is_waiting=(value)
    @is_waiting=value
    raise_is_waiting_changed
  end

  def raise_message_changed
    @message_changed_listeners.each { |b| b.call(self) }
  end

  def on_message_changed (&block)
    @message_changed_listeners << block
  end

  def save (settings)
    begin
      File.write('config/network.json', JSON.generate(settings))
    rescue Exception => ex
      puts ex.inspect
    end
  end

  def load
    begin
      JSON.parse(File.read('config/network.json'), {:symbolize_names => true})
    rescue Exception => ex
      puts ex.inspect
      {
          :player_name => 'Player 1',
          :server_ip => '127.0.0.1',
          :server_port => '5555',
          :client_ip => '127.0.0.1',
          :client_port => '5555'
      }
    end
  end

  def network_settings
    {
        :player_name => player_name,
        :server_ip => server_ip,
        :server_port => server_port,
        :client_ip => client_ip,
        :client_port => client_port
    }
  end

  def handle_error error
    puts error
    self.message = error
  end

  def add_is_waiting_changed_handler(&block)
    (@waiting_changed_handlers ||= []) << block
  end

  def raise_is_waiting_changed
    @waiting_changed_handlers.each {|h| h.call(self, is_waiting)} if @waiting_changed_handlers
  end

  private :raise_message_changed, :load, :handle_error
end