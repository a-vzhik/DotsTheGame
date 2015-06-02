class HotSeatGameModel
  attr_accessor :game, :grid
  def initialize
    json = JSON.parse(File.read('settings.json'), {:symbolize_names => true})
    @grid = Grid.new(json[:grid_size][0], json[:grid_size][1])
    @game = Game.new(grid)
  end
end