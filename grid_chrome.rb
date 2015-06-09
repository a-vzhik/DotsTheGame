class GridChrome < Qt::Widget

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
    @highlighted_dot = nil
  end

  def paintEvent(event)
    painter = Qt::Painter.new
    painter.begin(self)
    painter.fillRect(event.rect(), Qt::Brush.new(@background_color))

    paint painter

    painter.end
  end

  def paint(painter)
    # Body
    #painter.pen = Qt::Pen.new(Qt::Brush.new(Qt::Color.new('blue')), 2)
    painter.brush = Qt::Brush.new(@background_color)
    #painter.drawRect(boundingRect)
    #painter.setRenderHints 1
    painter.pen = Qt::Pen.new(Qt::Brush.new(Qt::Color.fromString('#DDD')), 1)

    for step in 1..@grid.horizontalDotsCount do
      horizontal = @grid_rect.left + @horizontal_gap * (step - 1)
      painter.drawLine(horizontal, boundingRect.top, horizontal, boundingRect.bottom)
    end

    for step in 1..@grid.verticalDotsCount do
      vertical = @grid_rect.top + @vertical_gap * (step - 1)
      painter.drawLine(boundingRect.left, vertical, boundingRect.right, vertical)
    end

    painter.brush = Qt::Brush.new(Qt::Color.fromString('#AADDDDDD'))
    painter.pen = Qt::Pen.new(Qt::Brush.new(Qt::Color.fromString('#66DDDDDD')), 1)

    path = Qt::PainterPath.new
    @grid.iterateDots do |dot|
      path.addEllipse(coordinateF(dot), @dot_radius, @dot_radius) if is_dot_available? dot
    end

    painter.drawPath(path)

    painter.pen = nil
    for player in @game.players
      painter.brush = player.settings.dot_fill
      player.unavailable_dots {|dot| paint_dot painter, dot, true}
    end

    for player in @game.players
      painter.brush = player.settings.capture_fill
      painter.pen = Qt::Pen.new(Qt::Brush.new(Qt::Color.fromString('#66DDDDDD')), 1)
      player.each_seizure do |s|
        points = Qt::Polygon.new(s.dots.map{|d| coordinate(d)})
        painter.drawPolygon(points)
      end
    end

    for player in @game.players
      path = Qt::PainterPath.new
      painter.brush = player.settings.dot_fill
      painter.pen = Qt::Pen.new(player.settings.capture_fill, 1)
      player.available_dots {|dot| path.addEllipse(coordinateF(dot), @dot_radius, @dot_radius)}
      #painter.fillPath(path, player.settings.dot_fill)
      painter.drawPath(path)
    end

    if @highlighted_dot !=nil then
      painter.brush = @game.active_player.settings.dot_fill
      painter.pen = Qt::Pen.new(@game.active_player.settings.capture_fill, 1)
      path = Qt::PainterPath.new
      path.addEllipse(coordinateF(@highlighted_dot), @dot_radius, @dot_radius)
      painter.drawPath(path)
    end
    #paint_dot(painter, @highlighted_dot, false) if @highlighted_dot != nil

  end

  def paint_dot (painter, dot, is_unavailable)
    if is_unavailable then
      cross = cross_polygon square(dot), @dot_radius / 2
      painter.drawPolygon(cross)
    else
      painter.drawEllipse(coordinate(dot), @dot_radius, @dot_radius)
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
    Qt::Point.new(
        @grid_rect.left + @horizontal_gap * dot.horizontalIndex,
        @grid_rect.top + @vertical_gap * dot.verticalIndex)
  end
  def coordinateF(dot)
    Qt::PointF.new(
        @grid_rect.left + @horizontal_gap * dot.horizontalIndex,
        @grid_rect.top + @vertical_gap * dot.verticalIndex)
  end

  def square(dot)
    coord = coordinate dot
    Qt::RectF.new(coord.x-@dot_radius, coord.y-@dot_radius, @dot_radius*2, @dot_radius*2)
  end

  def mouseMoveEvent(event)
    if !mouseTracking then
      event.ignore
      return
    end

    old_highlighted_dot = @highlighted_dot

    possible_row = ((event.pos().x - @grid_rect.left) / @horizontal_gap).round
    possible_col = ((event.pos().y - @grid_rect.top) / @vertical_gap).round

    possible_dot = Dot.new(possible_row.floor, possible_col)
    if square(possible_dot).contains(event.pos().x, event.pos().y) and is_dot_available? possible_dot then
      @highlighted_dot = possible_dot
    else
      @highlighted_dot = nil
    end

    repaint(boundingRect.left, boundingRect.top, boundingRect.width, boundingRect.height) if @highlighted_dot != old_highlighted_dot
  end

  def mousePressEvent(event)
    if event.button != Qt::LeftButton || !mouseTracking then
      event.ignore
      return
    end

    highlighted_dot = @highlighted_dot
    @highlighted_dot = nil
    send_dot_selected highlighted_dot if highlighted_dot != nil and is_empty? highlighted_dot

  end

  def send_dot_selected (dot)
    @dot_selected_listeners.each{|l| l.call (dot)}
  end

  def on_dot_selected (&block)
    @dot_selected_listeners << block if block != nil
  end

  def is_empty? dot
    for player in @game.players
      return false if player.all_dots.select{|d| d == dot}.count > 0
    end

    true
  end

  def boundingRect
    @bounding_rect
  end

  def setBoundingRect (rect)
    @bounding_rect = rect
    @grid_rect = Qt::RectF.new(
        boundingRect.left + @margin,
        boundingRect.top + @margin,
        boundingRect.width - 2*@margin,
        boundingRect.height - 2*@margin)

    @horizontal_gap = (@grid_rect.width / (@grid.horizontalDotsCount - 1)).round
    @vertical_gap = (@grid_rect.height / (@grid.verticalDotsCount - 1)).round

    @dot_radius = (@horizontal_gap / 7).round

    puts "setBoundingRect #{@bounding_rect}"
    repaint(boundingRect.left, boundingRect.top, boundingRect.width, boundingRect.height)
  end

  def event (ev)
    super ev
    if ev.type == Qt::Event.Resize then
      rect = Qt::RectF.new(0, 0, width, height);
      setBoundingRect(rect)
    end
  end

  def is_dot_available? (dot)
    for p in @game.players
      p.each_seizure do |s|
        return false if s.contains_dot? dot
      end
      p.all_dots do |d|
        return false if dot == d
      end
    end
    true
  end

end