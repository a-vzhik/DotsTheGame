class TabControl < Qt::Widget
  def initialize (parent = nil)
    super(parent)

    @tabWidget = Qt::TabWidget.new

    start_view = StartView.new @tabWidget
    start_view.on_new_hot_seat_game do
      run_hot_seat
    end

    @tabWidget.addTab(start_view, tr("Start a new game"))
    main_layout = Qt::GridLayout.new
    main_layout.addWidget(@tabWidget, 0, 0)

    setLayout main_layout
    setWindowState(Qt::WindowMaximized)
    setWindowTitle "Dots The Game"
  end

  def run_hot_seat
    view = GameView.new @tabWidget
    index = @tabWidget.addTab(view, tr("Hot seat game"))
    @tabWidget.setCurrentIndex index
  end

end