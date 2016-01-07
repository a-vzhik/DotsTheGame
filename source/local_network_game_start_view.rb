class LocalNetworkGameStartView < Qt::Widget
  extend Events

  slots 'raise_server_port_changed(const QString&)', 'raise_server_ip_changed(int)',
        'raise_client_ip_changed(const QString&)', 'raise_client_port_changed(const QString&)',
        'raise_player_name_changed(const QString&)', 'raise_server_start_required()',
        'raise_client_start_required()'

  attr_reader :port_text_edit

  define_event :server_start_required, :client_start_required

  def initialize(model, parent = nil)
    super(parent)

    @model = model

    text_edit_width = 350
    padding = 10
    button_style = "QPushButton{padding:#{padding}px}"

    main_layout = Qt::GridLayout.new do |gl|
      gl.setAlignment Qt::AlignVCenter

      name_layout = Qt::VBoxLayout.new do |vl|
        label = Qt::Label.new('Enter a player name:')
        vl.addWidget(label)

        @player_name_text_edit = Qt::LineEdit.new(@model.player_name)
        @player_name_text_edit.setMaximumWidth text_edit_width
        connect(@player_name_text_edit, SIGNAL('textChanged(const QString&)'), self, SLOT('raise_player_name_changed(const QString&)'))
        vl.addWidget(@player_name_text_edit)
      end
      gl.addLayout(name_layout, 0, 0, 1, -1, Qt::AlignHCenter)

      gl.addItem(Qt::SpacerItem.new(1, padding*5, Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed), 1, 0, 1, -1)

      gl.addWidget(Qt::Widget.new(), 2, 0)

      vbox_layout = Qt::GridLayout.new do |l|
        title = Qt::Label.new('CREATE A NEW GAME: ')
        title.setFontSize(title.font.pointSize * 2)
        l.addWidget(title, 0, 0, 1, -1)

        l.addItem(Qt::SpacerItem.new(1,padding), 1, 0, 1, -1)

        label = Qt::Label.new('IP address:')
        l.addWidget(label, 2, 0, 1, 1)

        @network_interfaces_combo_box = Qt::ComboBox.new
        ip_index = 0
        @model.network_interfaces.each do |ip|
          @network_interfaces_combo_box.addItem(ip)
          ip_index = @network_interfaces_combo_box.count - 1 if ip == @model.server_ip
        end
        @network_interfaces_combo_box.setCurrentIndex ip_index if @network_interfaces_combo_box.count > 0
        @network_interfaces_combo_box.setMaximumWidth text_edit_width
        connect(@network_interfaces_combo_box, SIGNAL('activated(int)'), self, SLOT('raise_server_ip_changed(int)'))
        l.addWidget(@network_interfaces_combo_box, 2, 1)

        #l.addItem(Qt::SpacerItem.new(1,padding), 1, 0, 1, -1)

        label = Qt::Label.new('Port:')
        l.addWidget(label, 3, 0, 1, 1)

        @port_text_edit = Qt::LineEdit.new()
        @port_text_edit.setInputMask '00000'
        @port_text_edit.setText @model.server_port
        @port_text_edit.setMaximumWidth text_edit_width
        connect(@port_text_edit, SIGNAL('textChanged(const QString&)'), self, SLOT('raise_server_port_changed(const QString&)'))
        l.addWidget(@port_text_edit, 3, 1)

        l.addItem(Qt::SpacerItem.new(1,padding), 4, 0, 1, -1)

        @server_button = Qt::PushButton.new('Create') do |b|
          b.setStyleSheet button_style
        end
        connect(@server_button, SIGNAL('clicked()'), self, SLOT('raise_server_start_required()'))
        l.addWidget(@server_button, 5, 0, 1, -1, Qt::AlignHCenter)
      end
      gl.addLayout(vbox_layout, 2, 1)

      gl.addItem(Qt::SpacerItem.new(padding*10, 1, Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed), 2, 2)

      vbox_layout = Qt::GridLayout.new do |l|
        title = Qt::Label.new('JOIN AN EXISTING GAME: ')
        title.setFontSize(title.font.pointSize * 2)
        l.addWidget(title, 0, 0, 1, -1)

        l.addItem(Qt::SpacerItem.new(1,padding), 1, 0, 1, -1)

        label = Qt::Label.new('IP address:')
        l.addWidget(label, 2, 0)

        @ip_text_edit = Qt::LineEdit.new(@model.client_ip)
        @ip_text_edit.setInputMask('000.000.000.000')
        @ip_text_edit.setMaximumWidth text_edit_width
        connect(@ip_text_edit, SIGNAL('textChanged(const QString&)'), self, SLOT('raise_client_ip_changed(const QString&)'))
        l.addWidget(@ip_text_edit, 2, 1)

        label = Qt::Label.new('Port:')
        l.addWidget(label, 4, 0)

        @port_text_edit2 = Qt::LineEdit.new()
        @port_text_edit2.setInputMask '00000'
        @port_text_edit2.setText @model.client_port
        @port_text_edit2.setMaximumWidth text_edit_width
        connect(@port_text_edit2, SIGNAL('textChanged(const QString&)'), self, SLOT('raise_client_port_changed(const QString&)'))
        l.addWidget(@port_text_edit2, 4, 1)

        l.addItem(Qt::SpacerItem.new(1,padding), 5, 0, 1, -1)

        @client_button = Qt::PushButton.new('Join') do |b|
          b.setStyleSheet button_style
        end

        connect(@client_button, SIGNAL('clicked()'), self, SLOT('raise_client_start_required()'))
        l.addWidget(@client_button, 6, 0, 1, -1, Qt::AlignHCenter)
      end
      gl.addLayout(vbox_layout, 2, 3)
      gl.addWidget(Qt::Widget.new(), 2, 4)

      @message_label = Qt::Label.new
      #@message_label.setMaximumWidth text_edit_width
      @message_label.setWordWrap true
      gl.addWidget(@message_label, 3, 0, 1, 5)

      gl.setColumnStretch 0, 2
      gl.setColumnStretch 1, 1
      gl.setColumnStretch 3, 1
      gl.setColumnStretch 4, 2
    end

    setLayout main_layout

    @model.on_message_changed { @message_label.setText @model.message }
    @model.add_is_waiting_changed_handler do
      @server_button.setDisabled @model.is_waiting
      @client_button.setDisabled @model.is_waiting
    end
  end

  def add_server_ip_changed_handler(&block)
    (@server_ip_changed_handlers ||= []) << block
  end

  def raise_server_ip_changed(index)
    value = @network_interfaces_combo_box.itemText(index)
    @server_ip_changed_handlers.each { |l| l.call(self, value) } if @server_ip_changed_handlers
  end

  def add_server_port_changed_handler(&block)
    (@server_port_changed_handlers ||= []) << block
  end

  def raise_server_port_changed(value)
    @server_port_changed_handlers.each { |l| l.call(self, value)} if @server_port_changed_handlers
  end

  def add_client_ip_changed_handler(&block)
    (@client_ip_changed_handlers ||= []) << block
  end

  def raise_client_ip_changed(value)
    @client_ip_changed_handlers.each { |l| l.call(self, value) } if @client_ip_changed_handlers
  end

  def add_client_port_changed_handler(&block)
    (@client_port_changed_handlers ||= []) << block
  end

  def raise_client_port_changed(value)
    @client_port_changed_handlers.each { |l| l.call(self, value)} if @client_port_changed_handlers
  end

  def add_player_name_changed_handler(&block)
    (@player_name_changed_handlers ||= []) << block
  end

  def raise_player_name_changed(value)
    @player_name_changed_handlers.each { |l| l.call(self, value) } if @player_name_changed_handlers
  end
end