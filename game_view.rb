class GameView < Qt::Widget
  def initialize (parent)
    super parent
    
    current_font = font;
    current_font.setPointSize 18
    setFont current_font
    
    grid = Grid.new(20, 20)
    game = Game.new(grid)
    @grid_chrome = GridChrome.new(self, grid, game)
   
    main_layout = Qt::GridLayout.new do |l|
      l.addWidget(PlayerChrome.new(game.players.first, {}, self), 0, 0)
      l.addWidget(@grid_chrome, 0, 1, 1, 3)    
      l.addWidget(PlayerChrome.new(game.players.last, {}, self), 0, 4)
    end
    setLayout main_layout
  end
end