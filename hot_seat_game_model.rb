class HotSeatGameModel

  attr_accessor :game, :grid

  def initialize (first_player_name, second_player_name)
    json = JSON.parse(File.read('settings.json'), {:symbolize_names => true})
    @grid = Grid.new(json[:grid_size][0], json[:grid_size][1])

    fp = Player.new(first_player_name, PlayerSettings.new(1, 'settings.json'))
    sp = Player.new(second_player_name, PlayerSettings.new(2, 'settings.json'));

    @game = Game.new(grid, fp, sp)
    @game_status_listeners = []
  end

  def accept_turn(dot)
    @game.accept_turn dot
    send_game_state_changed
  end

  def on_game_state_changed (&block)
    @game_status_listeners << block
  end

  def send_game_state_changed
    @game_status_listeners.each {|l| l.call}
  end

  private :send_game_state_changed
end