class GridChrome < Qt::Widget
  slots 'on_timeout()'

  def initialize(parent, model)
    super(parent)
    setMouseTracking(true)
    #setAcceptHoverEvents(true)
    @dot_selected_listeners = []

    @dot_radius = 6
    @grid = model.grid
    @game = model.game
    @background_color = Qt::Color.new('white')

    @margin = 10
    setBoundingRect Qt::RectF.new(0, 0, 400, 400)
    @is_invalidated = true

    @dot_selected_listeners = []
    @highlighted_dot = nil
  end

  def paintEvent(event)
    painter = Qt::Painter.new
    painter.begin(self)
    painter.fillRect(event.rect(), Qt::Brush.new(@background_color))

    paint painter

    painter.end

    @is_invalidated = false
  end

  def paint(painter)
    #painter.setRenderHints 1

    path = Qt::PainterPath.new
    for step in 1..@grid.horizontalDotsCount do
      horizontal = @grid_rect.left + @horizontal_gap_between_dots * (step - 1)
      path.moveTo(horizontal, boundingRect.top)
      path.lineTo(horizontal, boundingRect.bottom)
    end

    for step in 1..@grid.verticalDotsCount do
      vertical = @grid_rect.top + @vertical_gap_between_dots * (step - 1)
      path.moveTo(boundingRect.left, vertical)
      path.lineTo(boundingRect.right, vertical)
    end

    painter.drawPath(nil, Qt::Pen.new(Qt::Brush.new(Qt::Color.fromString('#DDD')), 1), path)

    empty_dot_fill = Qt::Brush.new(Qt::Color.fromString('#AADDDDDD'))
    empty_dot_stroke = Qt::Brush.new(Qt::Color.fromString('#66DDDDDD'))
    empty_dot_pen = Qt::Pen.new(empty_dot_stroke, 1)

    path = Qt::PainterPath.new
    @grid.empty_dots.each {|dot| path.addEllipse(coordinateF(dot), @dot_radius, @dot_radius)}

    painter.drawPath(empty_dot_fill, empty_dot_pen, path)

    for player in @game.players
      path = Qt::PainterPath.new
      player.unavailable_dots.each {|d| path.addPolygon(cross_polygon(square(d), @dot_radius / 2))}
      painter.drawPath(player.settings.dot_fill, Qt::Pen.new(player.settings.capture_fill, 1), path)
    end

    for player in @game.players
      player.each_seizure do |s|
        polygon = Qt::PolygonF.new(s.dots.map{|d| coordinateF(d)})
        painter.drawPolygon(player.settings.capture_fill, empty_dot_pen, polygon)
      end
    end

    for player in @game.players
      path = Qt::PainterPath.new
      player.available_dots {|dot| path.addEllipse(coordinateF(dot), @dot_radius, @dot_radius)}
      painter.drawPath(player.settings.dot_fill, Qt::Pen.new(player.settings.capture_fill, 1), path)
    end

    if @highlighted_dot != nil then
      path = Qt::PainterPath.new
      path.addEllipse(coordinateF(@highlighted_dot), @dot_radius, @dot_radius)
      painter.drawPath(@game.active_player.settings.dot_fill, Qt::Pen.new(@game.active_player.settings.capture_fill, 1), path)
      #painter.drawPath(@brush, Qt::Pen.new(@game.active_player.settings.capture_fill, 1), path)
    end
  end

  def cross_polygon (rect, thickness)
    center  = rect.center
    points = []
    points << Qt::PointF.new(center.x, center.y - thickness)
    points << Qt::PointF.new(rect.right - thickness, rect.top)
    points << Qt::PointF.new(rect.right, rect.top + thickness)
    points << Qt::PointF.new(center.x + thickness, center.y)
    points << Qt::PointF.new(rect.right, rect.bottom - thickness)
    points << Qt::PointF.new(rect.right - thickness, rect.bottom)
    points << Qt::PointF.new(center.x, center.y + thickness)
    points << Qt::PointF.new(rect.left + thickness, rect.bottom)
    points << Qt::PointF.new(rect.left, rect.bottom - thickness)
    points << Qt::PointF.new(center.x - thickness, center.y)
    points << Qt::PointF.new(rect.left, rect.top + thickness)
    points << Qt::PointF.new(rect.left + thickness, rect.top)
    points << Qt::PointF.new(center.x, center.y - thickness)
    Qt::PolygonF.new(points)
  end

  def coordinate(dot)
    Qt::PointF.new(
        @grid_rect.left + @horizontal_gap_between_dots * dot.horizontalIndex,
        @grid_rect.top + @vertical_gap_between_dots * dot.verticalIndex)
  end

  def coordinateF(dot)
    Qt::PointF.new(
        @grid_rect.left + @horizontal_gap_between_dots * dot.horizontalIndex,
        @grid_rect.top + @vertical_gap_between_dots * dot.verticalIndex)
  end

  def square(dot)
    coord = coordinateF(dot)
    Qt::RectF.new(coord.x - @dot_radius, coord.y - @dot_radius, @dot_radius * 2, @dot_radius * 2)
  end

  def boundingRect
    @bounding_rect
  end

  def setBoundingRect (rect)
    @bounding_rect = rect
    @grid_rect = Qt::RectF.new(rect).adjusted(@margin)
    @horizontal_gap_between_dots = (@grid_rect.width / (@grid.horizontalDotsCount - 1))
    @vertical_gap_between_dots = (@grid_rect.height / (@grid.verticalDotsCount - 1))
    @dot_radius = (@horizontal_gap_between_dots / 7)

    update
  end

  def event (ev)
    super(ev)
    if ev.type == Qt::Event.Resize then
      rect = Qt::RectF.new(0, 0, width, height);
      setBoundingRect(rect)
    end
  end

  def mouseMoveEvent(event)
    if !mouseTracking then
      event.ignore
      return
    end

    old_highlighted_dot = @highlighted_dot

    possible_row = ((event.pos().x - @grid_rect.left) / @horizontal_gap_between_dots).round
    possible_col = ((event.pos().y - @grid_rect.top) / @vertical_gap_between_dots).round

    possible_dot = Dot.new(possible_row.floor, possible_col)
    if square(possible_dot).contains(event.pos().x, event.pos().y) and @grid.empty_dots.contains? possible_dot then
      #setCursor(Qt::Cursor.new(Qt::BlankCursor))
      @highlighted_dot = possible_dot
    else
      #setCursor(Qt::Cursor.new(Qt::ArrowCursor))
      @highlighted_dot = nil
    end

    update if @highlighted_dot != old_highlighted_dot
  end

  def mousePressEvent(event)
    if event.button != Qt::LeftButton || !mouseTracking then
      event.ignore
    else
      highlighted_dot = @highlighted_dot
      @highlighted_dot = nil
      notify_dot_selected(highlighted_dot) if highlighted_dot != nil and @grid.empty_dots.contains? highlighted_dot
    end
  end

  def on_dot_selected (&block)
    @dot_selected_listeners << block if block != nil
  end

  def notify_dot_selected (dot)
    @dot_selected_listeners.each{|l| l.call dot}
  end

  private :notify_dot_selected
end