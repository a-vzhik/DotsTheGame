class PlayerChrome < Qt::Widget
  def initialize(game, player, parent = nil)
    super(parent)
    @player = player
  end

  def paintEvent(event)
    puts "Player chrome paint #{event.rect}"

    painter = Qt::Painter.new()
    painter.begin(self)
    painter.fillRect(event.rect(), Qt::Brush.new(Qt::white))

    #current_font = font
    #current_font.setBold @player.is_active
    #setFont current_font

    padding = 10

    required_player_name_rect = Qt::Rect.new(0, 50, width, height)
    flags = Qt::AlignHCenter | Qt::TextWrapAnywhere
    actual_player_name_rect = painter.fontMetrics.boundingRect(required_player_name_rect, flags, @player.name)
    player_name_frame = actual_player_name_rect.adjusted(-padding, -padding, padding, padding)

    if @player.is_active then
      painter.drawRect(@player.settings.capture_fill, nil, player_name_frame)
    end

    painter.drawText(actual_player_name_rect, flags, "#{@player.name}")

    current_font = font
    old_point_size = current_font.pointSize
    current_font.setPointSize 64
    painter.setFont current_font

    painter.pen = Qt::Pen.new(@player.settings.dot_fill, 1)

    required_player_score_rect = Qt::Rect.new(0, player_name_frame.bottom + padding, width, height)
    painter.drawText(required_player_score_rect , flags, "#{@player.score}")

    painter.end

  end
end