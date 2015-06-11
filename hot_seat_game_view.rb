class HotSeatGameView < Qt::Widget
  def initialize (controller, parent = nil)
    super parent

    setMouseTracking(true)
    @controller = controller
    @controller.on_game_state_changed do
      @controller.view.invalidate
      #repaint 0, 0, width, height
    end

    current_font = font;
    current_font.setPointSize 18
    setFont current_font

    main_layout = Qt::GridLayout.new do |l|
      l.addWidget(PlayerChrome.new(@controller.model.game, @controller.model.game.players.first, self), 0, 0)
      l.addWidget(@controller.view, 0, 1, 1, 3)
      l.addWidget(@controller.mouse_view, 0, 1, 1, 3)
      l.addWidget(PlayerChrome.new(@controller.model.game, @controller.model.game.players.last, self), 0, 4)
    end
    setLayout main_layout
  end

  def mouseMoveEvent(e)
    puts e.pos
  end
end