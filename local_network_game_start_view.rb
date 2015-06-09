class LocalNetworkGameStartView < Qt::Widget
  slots 'run_as_server()', 'run_as_client()'
  def initialize(parent = nil)
    super(parent)

    stack_layout = Qt::VBoxLayout.new do |l|
      text_edit_width = 350
      padding = 10

      label = Qt::Label.new ("Enter a player name:")
      l.addWidget(label)

      @player_name_text_edit = Qt::LineEdit.new('Player 1')
      @player_name_text_edit.setMaximumWidth text_edit_width
      l.addWidget(@player_name_text_edit)

      l.addSpacerItem(Qt::SpacerItem.new(1,padding))

      label = Qt::Label.new ("Enter an IP address:")
      l.addWidget(label)

      @ip_text_edit = Qt::LineEdit.new('127.0.0.1')
      @ip_text_edit.setInputMask('000.000.000.000')
      @ip_text_edit.setMaximumWidth text_edit_width
      l.addWidget(@ip_text_edit)

      l.addSpacerItem(Qt::SpacerItem.new(1,padding))

      label = Qt::Label.new ("Enter a port:")
      l.addWidget(label)

      @port_text_edit = Qt::LineEdit.new()
      @port_text_edit.setInputMask '00000'
      @port_text_edit.setText '5555'
      @port_text_edit.setMaximumWidth text_edit_width
      l.addWidget(@port_text_edit)

      l.addSpacerItem(Qt::SpacerItem.new(1,padding))

      @server_button = Qt::PushButton.new('Run a new game')
      connect(@server_button, SIGNAL('clicked()'), self, SLOT('run_as_server()'))
      l.addWidget(@server_button)

      l.addSpacerItem(Qt::SpacerItem.new(1,padding))

      @client_button = Qt::PushButton.new('Connect to a game')
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

    try_create_server(@ip_text_edit.text, port) do |srv|
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
              grid_chrome = GridChrome.new(self, model)
              controller = SocketGameController.new(@server, model, grid_chrome)
              notify_game_created controller
          rescue Exception => e
            handle_error e.inspect
          end
        end
      end
      @message_label.setText 'Game has been started. Waiting for another player\'s connection...'
    end
  end

  def run_as_client
    port = @port_text_edit.text.to_i
    if(port == 0 || port > 65535)
      @message_label.text = 'Invalid port. Please pick up a value between 0 and 65535'
      return
    end

    begin
      server = TCPSocket.open(@ip_text_edit.text, port)
      @client = Client.new(server)

      @client.on_new_game do |game|
        Qt.execute_in_main_thread do
          model = HotSeatGameModel.new game[:players][0], game[:players][1]
          grid_chrome = GridChrome.new(self, model)
          controller = SocketGameController.new(@client, model, grid_chrome)
          notify_game_created controller
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
end