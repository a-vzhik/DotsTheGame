class Qt::RectF
  def to_s
    "#{super} (#{left}, #{top}, #{width}, #{height})"
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
    if params.length == 3 and (params[0].class == Qt::Brush or params[0].class == NilClass) and (params[1].class == Qt::Pen or params[1].class == NilClass) and (params[2].class == Qt::Rect or params[2].class == Qt::RectF)
      brush = params[0]
      pen = params[1]
      rect = params[2]
      fillRect(rect, brush) if brush != nil
      params = [rect]
      executeWithPen(pen) {super} if pen != nil
    else
      super
    end
  end

  private
  def executeWithPen(pen, &block)
    old_pen, self.pen = self.pen, pen
    block.call
    self.pen = old_pen
  end
end