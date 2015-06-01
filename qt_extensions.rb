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