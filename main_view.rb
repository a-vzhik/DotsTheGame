class MainView < Qt::Widget
  def initialize (parent = nil)
    super(parent)

    @tabWidget = Qt::TabWidget.new
    #@tabWidget.setTabsClosable true

    start_view = StartView.new @tabWidget
    start_view.on_new_hot_seat_game { run_hot_seat }
    start_view.on_new_local_network_game { run_local_network }


    @tabWidget.addTab(start_view, tr('Start a new game'))
    main_layout = Qt::GridLayout.new
    main_layout.addWidget(@tabWidget, 0, 0)

    setLayout main_layout
    setWindowState(Qt::WindowMaximized)
    setWindowTitle 'Dots The Game'
  end

  def run_hot_seat
    model = HotSeatGameModel.new('Player 1', 'Player 2')
    view = HotSeatGameView.new(@tabWidget, model)
    @controller = HotSeatGameController.new(model, view)

    add_and_activate_tab view, tr('Hot seat game')
  end

  def run_local_network
    view = LocalNetworkGameStartView.new @tabWidget
    add_and_activate_tab view, tr('Local network game')
    view.on_game_created do |game_view|
      add_and_activate_tab game_view, tr('Local network game')
      remove_tab view
    end
  end

  def add_and_activate_tab (tab, title)
    index = @tabWidget.addTab(tab, title)
    @tabWidget.setCurrentIndex index
  end

  def remove_tab (tab)
    @tabWidget.removeTab(@tabWidget.indexOf tab)
  end
end