require 'delegate'

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