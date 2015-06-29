class LocalNetworkGameStartView < Qt::Widget
  slots 'run_as_server()', 'run_as_client()'
  def initialize(parent = nil)
    super(parent)

    settings = load

    stack_layout = Qt::VBoxLayout.new do |l|
      text_edit_width = 350
      padding = 10

      label = Qt::Label.new('Enter a player name:')
      l.addWidget(label)

      @player_name_text_edit = Qt::LineEdit.new(settings[:player_name])
      @player_name_text_edit.setMaximumWidth text_edit_width
      l.addWidget(@player_name_text_edit)

      l.addSpacerItem(Qt::SpacerItem.new(1,padding*3))

      label = Qt::Label.new('Enter an IP address:')
      l.addWidget(label)

      @network_interfaces_combo_box = Qt::ComboBox.new
      ip_index = 0
      Socket.ip_address_list.each do |i|
        if i.ipv4?
          @network_interfaces_combo_box.addItem(i.ip_address)
          ip_index = @network_interfaces_combo_box.count - 1 if i.ip_address == settings[:server_ip] 
        end  
      end  
      @network_interfaces_combo_box.setCurrentIndex ip_index if @network_interfaces_combo_box.count > 0
      @network_interfaces_combo_box.setMaximumWidth text_edit_width
      l.addWidget(@network_interfaces_combo_box)

      l.addSpacerItem(Qt::SpacerItem.new(1,padding))

      label = Qt::Label.new('Enter a port:')
      l.addWidget(label)

      @port_text_edit = Qt::LineEdit.new()
      @port_text_edit.setInputMask '00000'
      @port_text_edit.setText settings[:server_port]
      @port_text_edit.setMaximumWidth text_edit_width
      l.addWidget(@port_text_edit)

      l.addSpacerItem(Qt::SpacerItem.new(1,padding))

      @server_button = Qt::PushButton.new('Create a new game')
      connect(@server_button, SIGNAL('clicked()'), self, SLOT('run_as_server()'))
      l.addWidget(@server_button)

      l.addSpacerItem(Qt::SpacerItem.new(1,padding*3))
      
      label = Qt::Label.new('Enter an IP address:')
      l.addWidget(label)

      @ip_text_edit = Qt::LineEdit.new(settings[:client_ip])
      @ip_text_edit.setInputMask('000.000.000.000')
      @ip_text_edit.setMaximumWidth text_edit_width
      l.addWidget(@ip_text_edit)
      
      l.addSpacerItem(Qt::SpacerItem.new(1,padding))

      label = Qt::Label.new('Enter a port:')
      l.addWidget(label)

      @port_text_edit2 = Qt::LineEdit.new()
      @port_text_edit2.setInputMask '00000'
      @port_text_edit2.setText settings[:client_port]
      @port_text_edit2.setMaximumWidth text_edit_width
      l.addWidget(@port_text_edit2)

      l.addSpacerItem(Qt::SpacerItem.new(1,padding))

      @client_button = Qt::PushButton.new('Join to a game')
      connect(@client_button, SIGNAL('clicked()'), self, SLOT('run_as_client()'))
      l.addWidget(@client_button)

      l.addSpacerItem(Qt::SpacerItem.new(1,padding))
      @message_label = Qt::Label.new
      @message_label.setMaximumWidth text_edit_width
      @message_label.setWordWrap true
      l.addWidget(@message_label)
    end

    grid_layout = Qt::GridLayout.new do |l|
      l.setAlignment Qt::AlignVCenter
      l.addWidget(Qt::Widget.new, 0, 0)
      l.addLayout(stack_layout, 0, 1)
      l.addWidget(Qt::Widget.new, 0, 2)
    end

     setLayout grid_layout
  end

  def try_create_server (ip, port, &block)
    begin
      server = Server.new(ip, port)
      block.call server
    rescue Exception => e
      handle_error e.inspect
    end
  end

  def handle_error error
    puts error
    @message_label.setText error
  end

  def run_as_server
    port = @port_text_edit.text.to_i
    if(port == 0 || port > 65535)
      @message_label.text = 'Invalid port. Please pick up a value between 0 and 65535'
      return
    end

    save network_settings

    try_create_server(@network_interfaces_combo_box.itemText(@network_interfaces_combo_box.currentIndex), port) do |srv|
      @server = srv
      @server_button.setDisabled true
      @server.on_candidates_changed do |s|
        Qt.execute_in_main_thread do
          first_player_name = @player_name_text_edit.text.to_s
          second_player_name = s.candidates.keys.first
          begin
            game = {:message_type => 'new_game', :game => { :players => [first_player_name, second_player_name]}}
            @server.send_new_game game
            model = HotSeatGameModel.new(first_player_name, second_player_name)
            view = HotSeatGameView.new(parent, model)
            SocketGameController.new(@server, model, view)
            notify_game_created view
          rescue Exception => e
            handle_error e.inspect
          end
        end
      end
      @message_label.setText 'Game has been started. Waiting for another player\'s connection...'
    end
  end

  def run_as_client
    port = @port_text_edit2.text.to_i
    if(port == 0 || port > 65535)
      @message_label.text = 'Invalid port. Please pick up a value between 0 and 65535'
      return
    end

    save network_settings

    begin
      server = TCPSocket.open(@ip_text_edit.text, port)
      @client = Client.new(server)

      @client.on_new_game do |game|
        Qt.execute_in_main_thread do
          model = HotSeatGameModel.new game[:players][0], game[:players][1]
          view = HotSeatGameView.new(parent, model)
          SocketGameController.new(@client, model, view)
          notify_game_created view
        end
      end

      @client.send_introduce_message @player_name_text_edit.text
      @client_button.setDisabled true
    rescue Exception => e
      handle_error e.inspect
    end
  end
  
  def on_game_created (&block)
    @game_created_listener = block if block
  end

  def notify_game_created (controller)
    @game_created_listener.call controller if @game_created_listener
  end

  def save (settings)
    begin
      File.write('network.json', JSON.generate(settings))
    rescue Exception => ex
      puts ex.inspect
    end  
  end
  
  def load 
    begin
      JSON.parse(File.read('network.json'), {:symbolize_names => true})
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
      :player_name => @player_name_text_edit.text, 
      :server_ip => @network_interfaces_combo_box.itemText(@network_interfaces_combo_box.currentIndex), 
      :server_port => @port_text_edit.text, 
      :client_ip => @ip_text_edit.text, 
      :client_port => @port_text_edit2.text
    }    
  end

  private :notify_game_created, :try_create_server, :run_as_server, 
          :run_as_client, :handle_error, :save, :load, :network_settings 
end