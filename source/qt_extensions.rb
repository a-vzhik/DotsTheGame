class Qt::RectF
  def to_s
    "#{super} (#{left}, #{top}, #{width}, #{height})"
  end

  def adjusted(*params)
    if params.length == 1 then
      super(params[0], params[0], -params[0], -params[0])
    else
      super
    end
  end
end

class Qt::Rect
  def to_s
    "#{super} (#{left}, #{top}, #{width}, #{height})"
  end
end

class Qt::PointF
  def to_s
    "#{super} (#{x}, #{y})"
  end
end

class Qt::Point
  def to_s
    "#{super} (#{x}, #{y})"
  end
end

class Qt::Color
  def makeTransparent
    Qt::Color.new(red, green, blue, 0)
  end

  def self.fromString(str)
    data = /\#(\h\h)(\h\h)(\h\h)(\h\h)/.match(str)
    if data != nil then
      Qt::Color.new(data[2].to_i(16), data[3].to_i(16), data[4].to_i(16), data[1].to_i(16))
    else
      Qt::Color.new(str)
    end
  end
end

class Qt::Painter
	def drawRect (*params)
    if params.length == 3 and isBrushOrNil(params[0]) and isPenOrNil(params[1]) and isRect(params[2]) then
      executeWithBrushAndPen(params[0], params[1]) {super(params[2])}
    else
      super
    end
  end

  def drawPolygon (*params)
    if params.length == 3 and isBrushOrNil(params[0]) and isPenOrNil(params[1]) and isPolygon(params[2]) then
      executeWithBrushAndPen(params[0], params[1]) {super(params[2])}
    else
      super
    end
  end

  def drawPath (*params)
    if params.length == 3 and isBrushOrNil(params[0]) and isPenOrNil(params[1]) and isPath(params[2]) then
      executeWithBrushAndPen(params[0], params[1]) {super(params[2])}
    else
      super
    end
  end

  def executeWithPen(pen, &block)
    old_pen, self.pen = self.pen, pen
    block.call
    self.pen = old_pen
  end

  def executeWithBrushAndPen(brush, pen, &block)
    old_brush, old_pen, self.brush, self.pen = self.brush, self.pen, brush, pen
    block.call
    self.brush, self.pen, = old_brush, old_pen
  end

  def isBrushOrNil (param)
    param.class == Qt::Brush or param.class == NilClass
  end

  def isPenOrNil (param)
    param.class == Qt::Pen or param.class == NilClass
  end

  def isRect (param)
    param.class == Qt::Rect or param.class == Qt::RectF
  end

  def isPolygon (param)
    param.class == Qt::Polygon or param.class == Qt::PolygonF
  end

  def isPath (param)
    param.class == Qt::PainterPath
  end

  private :executeWithPen, :executeWithBrushAndPen, :isPolygon, :isPenOrNil, :isBrushOrNil, :isRect, :isPath
end

module WidgetExtensions
  def setBackground(color_or_brush)
    setAutoFillBackground(true)
    current_palette = palette
    if color_or_brush.class == Qt::Brush then
      current_palette.setBrush(Qt::Palette::Background, color_or_brush)
    else
      current_palette.setColor(Qt::Palette::Background, color_or_brush)
    end
    setPalette(current_palette)
  end

  def setFontSize(newSize)
    current_font = font
    current_font.setPointSize newSize
    setFont current_font
  end
end

class Qt::Widget
  include WidgetExtensions
end

class Qt::Label
  include WidgetExtensions
end

class Qt::PushButton
  include WidgetExtensions
end