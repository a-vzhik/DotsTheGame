class MainView < Qt::Widget
  def initialize (parent = nil)
    super(parent)

    @tab_control = Qt::TabWidget.new
    #@tabWidget.setTabsClosable true

    start_view = StartView.new @tab_control
    start_view.on_new_hot_seat_game { run_hot_seat }
    start_view.on_new_local_network_game { run_local_network }


    @tab_control.addTab(start_view, tr('Start a new game'))
    main_layout = Qt::GridLayout.new
    main_layout.addWidget(@tab_control, 0, 0)

    setLayout main_layout
    setWindowState(Qt::WindowMaximized)
    setWindowTitle 'Dots The Game'
  end

  def run_hot_seat
    model = HotSeatGameModel.new('Player 1', 'Player 2')
    view = HotSeatGameView.new(@tab_control, model)
    @controller = HotSeatGameController.new(model, view)

    add_and_activate_tab view, tr('Hot seat game')
  end

  def run_local_network
    view = LocalNetworkGameStartView.new @tab_control
    view.on_game_created do |game_view|
      add_and_activate_tab game_view, tr('Local network game')
      remove_tab view
    end
    add_and_activate_tab view, tr('Local network game')
  end

  def add_and_activate_tab (tab, title)
    index = @tab_control.addTab(tab, title)
    @tab_control.setCurrentIndex index
  end

  def remove_tab (tab)
    @tab_control.removeTab(@tab_control.indexOf tab)
  end
end