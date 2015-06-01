class PlayerChrome < Qt::Widget
  def initialize(player, player_settings, parent = nil)
    super(parent)
    
    @player = player
    @player_settings = player_settings
  end
  
  def paintEvent(event)
    painter = Qt::Painter.new
    painter.begin(self)
    painter.fillRect(event.rect(), Qt::Brush.new(Qt::white))

    painter.drawText(Qt::RectF.new(0, 50, width, height), Qt::AlignHCenter | Qt::TextWrapAnywhere, "#{@player.name}\n#{@player.captured_dots_count}")  
    
    painter.end
    
  end
end