class HotSeatGameView < Qt::Widget
  def initialize (parent, model)
    super(parent)

    @model = model
    @model.on_game_state_changed {update}

    current_font = font;
    current_font.setPointSize 18
    setFont current_font

    main_layout = Qt::GridLayout.new do |l|
      l.addWidget(PlayerChrome.new(@model.game, @model.game.players.first, self), 0, 0)
      @grid_chrome = GridChrome.new(self, @model)
      l.addWidget(@grid_chrome, 0, 1, 1, 3)
      l.addWidget(PlayerChrome.new(@model.game, @model.game.players.last, self), 0, 4)
    end
    setLayout main_layout
  end

  def mouse_layer
    @grid_chrome
  end
end