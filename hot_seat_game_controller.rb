class HotSeatGameController
  def initialize (game_model, game_view)
    @game_status_listeners = []
    @game_model = game_model
    @game_view = game_view
    game_view.on_dot_selected {|dot| on_dot_selected dot}
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