class StartView < Qt::Widget
  slots 'run_hot_seat()', 'run_local_network()'

  def initialize(parent = nil)
    super(parent)

    current_font = font
    current_font.setPointSize 24
    setFont current_font

    hot_seat_button = Qt::PushButton.new("Hot seat")
    hot_seat_button.setMinimumHeight 75
    connect(hot_seat_button, SIGNAL('clicked()'), self, SLOT('run_hot_seat()'))

    local_network_button = Qt::PushButton.new("Local network")
    local_network_button.setMinimumHeight 75
    connect(local_network_button, SIGNAL('clicked()'), self, SLOT('run_local_network()'))

    buttons_layout = Qt::VBoxLayout.new()
    buttons_layout.addWidget(hot_seat_button)
    buttons_layout.addSpacerItem(Qt::SpacerItem.new(1,50))
    buttons_layout.addWidget(local_network_button)

    background_svg = Qt::SvgWidget.new('media/icons/grid.svg')

    main_layout = Qt::GridLayout.new

    main_layout.addWidget(background_svg, 0, 0, 3, 3)
    main_layout.addWidget(Qt::Widget.new(), 0, 0)
    main_layout.addWidget(Qt::Widget.new(), 0, 1)
    main_layout.addWidget(Qt::Widget.new(), 1, 1)
    main_layout.addWidget(Qt::Widget.new(), 2, 1)
    main_layout.addLayout(buttons_layout, 1, 1)
    #main_layout.setAlignment(Qt::AlignHCenter )
    setLayout main_layout

    setWindowTitle(tr("Dots The Game"))
    resize(500, 500)
  end

  def on_new_hot_seat_game(&block)
    @new_hot_seat_game_listener = block
  end

  def run_hot_seat
    @new_hot_seat_game_listener.call if @new_hot_seat_game_listener
  end

  def on_new_local_network_game(&block)
    @new_local_network_game_listener = block
  end

  def run_local_network
    @new_local_network_game_listener.call if @new_local_network_game_listener
  end

end