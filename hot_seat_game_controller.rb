class HotSeatGameController
  def initialize (game_model, game_view)
    @game_model = game_model
    @game_view = game_view
    @mouse_layer = mouse_view
    game_view.mouse_layer.on_dot_selected {|dot| on_dot_selected dot}

    #@timer = Timer.new
    #@timer.on_elapsed {  }
    #@timer.start(10)
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

  def on_dot_selected (dot)
    @game_model.accept_turn(dot)
  end
end