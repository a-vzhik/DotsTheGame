class HotSeatGameModel
  attr_accessor :game, :grid
  def initialize (first_player_name, second_player_name)
    json = JSON.parse(File.read('settings.json'), {:symbolize_names => true})
    @grid = Grid.new(json[:grid_size][0], json[:grid_size][1])

    fp = Player.new(first_player_name, PlayerSettings.new(1, 'settings.json'))
    sp = Player.new(second_player_name, PlayerSettings.new(2, 'settings.json'));

    @game = Game.new(grid, fp, sp)
  end
end