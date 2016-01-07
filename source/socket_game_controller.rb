class SocketGameController
  attr_accessor :game, :grid
  def initialize(server_or_client, game_model, game_view)
    @game_status_listeners = []

    @game_model = game_model
    @game_view = game_view
    @mouse_layer = game_view.mouse_layer

    if server_or_client.class == Client
      @mouse_layer.setMouseTracking false
    end

    @mouse_layer.on_dot_selected do |dot|
      @game_model.accept_turn(dot)
      @mouse_layer.setMouseTracking false
      server_or_client.send_data dot
    end

    server_or_client.on_turn_accepted do |dot|
      Qt.execute_in_main_thread do
        @game_model.accept_turn(dot)
        @mouse_layer.setMouseTracking true
      end
    end
  end

  def model
    @game_model
  end

  def view
    @game_view
  end

  def mouse_view
    @mouse_layer
  end
end