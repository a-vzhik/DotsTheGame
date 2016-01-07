class LocalNetworkGameStartController
  extend Events

  define_event :game_created

  def initialize(model, view)
    @model, @view = model, view

    view.add_server_port_changed_handler { |sender, port| @model.server_port = port }
    view.add_server_ip_changed_handler { |sender, ip| @model.server_ip = ip }
    view.add_client_port_changed_handler { |sender, port| @model.client_port = port }
    view.add_client_ip_changed_handler { |sender, ip| @model.client_ip = ip }
    view.add_player_name_changed_handler{ |sender, name| @model.player_name = name }

    view.when_server_start_required { run_as_server }
    view.when_client_start_required { run_as_client }
  end

  def handle_error(error)
    puts error
    @model.message = error
  end

  def run_as_server
    port = @model.server_port.to_i

    if(port == 0 || port > 65535)
      self.message = 'Invalid port. Please pick up a value between 0 and 65535'
      return
    end

    @model.save @model.network_settings

    try_create_server(@model.server_ip, port) do |srv|
      @model.is_waiting = true

      srv.on_candidates_changed do |s|
        Qt.execute_in_main_thread do
          first_player_name = @model.player_name
          second_player_name = s.candidates.keys.first
          begin
            game = {:message_type => 'new_game', :game => { :players => [first_player_name, second_player_name]}}
            srv.send_new_game game
            model = HotSeatGameModel.new(first_player_name, second_player_name)
            view = HotSeatGameView.new(@view.parent, model)
            SocketGameController.new(srv, model, view)
            raise_game_created view
          rescue Exception => e
            handle_error e.inspect
          end
        end
      end
      @model.message = 'Game has been started. Waiting for another player\'s connection...'
    end
  end

  def run_as_client
    port = @model.client_port.to_i

    if(port  == 0 || port > 65535)
      self.message = 'Invalid port. Please pick up a value between 0 and 65535'
      return
    end

    @model.save @model.network_settings

    begin
      server = TCPSocket.open(@model.client_ip, port)
      client = Client.new(server)

      client.on_new_game do |game|
        Qt.execute_in_main_thread do
          model = HotSeatGameModel.new game[:players][0], game[:players][1]
          view = HotSeatGameView.new(@view.parent, model)
          SocketGameController.new(client, model, view)
          raise_game_created view
        end
      end

      client.send_introduce_message @model.player_name
      @model.is_waiting = true
    rescue Exception => e
      @model.message = e.inspect
    end
  end

  def try_create_server (ip, port, &block)
    begin
      server = Server.new(ip, port)
      block.call server
    rescue Exception => e
      handle_error e.inspect
    end
  end

  private :try_create_server, :run_as_server, :run_as_client, :handle_error

end