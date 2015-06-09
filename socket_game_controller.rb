class SocketGameController
  attr_accessor :game, :grid
  def initialize(server_or_client, game_model, game_view)
    @game_status_listeners = []

    @game_model = game_model
    @game_view = game_view

    if server_or_client.class == Client
      @game_view.setMouseTracking false
    end

    game_view.on_dot_selected do |dot|
      on_dot_selected dot
      @game_view.setMouseTracking false
      server_or_client.send_data dot
    end

    server_or_client.on_turn_accepted do |dot|
      Qt.execute_in_main_thread do
        on_dot_selected dot
        @game_view.setMouseTracking true
      end
    end
  end

  def model
    @game_model
  end

  def view
    @game_view
  end

  def on_dot_selected (dot)
    @game_model.game.accept_turn dot
    send_game_state_changed
  end

  def on_game_state_changed (&block)
    @game_status_listeners << block
  end

  def send_game_state_changed
    @game_status_listeners.each {|l| l.call}
  end

end