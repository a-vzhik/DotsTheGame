class Segment
  attr_reader :begin_point, :end_point
  def initialize(begin_point, end_point)
    @begin_point = begin_point
    @end_point = end_point
  end
  
  def intersects? (another_segment)
    p1 = begin_point.to_a
    p2 = end_point.to_a
    p3 = another_segment.begin_point.to_a
    p4 = another_segment.end_point.to_a

    d1 = Segment.direction(p3, p4, p1)
    d2 = Segment.direction(p3, p4, p2)
    d3 = Segment.direction(p1, p2, p3)
    d4 = Segment.direction(p1, p2, p4)
    
    if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)) then
      return true
    elsif d1 == 0 and Segment.on_segment(p3, p4, p1) then
      return true
    elsif d2 == 0 and Segment.on_segment(p3, p4, p2) then
      return true
    elsif d3 == 0 and Segment.on_segment(p1, p2, p3) then
      return true
    elsif d4 == 0 and Segment.on_segment(p1, p2, p4) then
      return true
    end
    
    false    
  end
  
  def self.direction(pi, pj, pk)
    #(p1 - p0)x(p2 - p0) = (x1 - x0)(y2 - y0) - (x2 - x0)(y1 - y0)
    #(pk - pi)x(pj - pi) = (xk - xi)(yj - yi) - (xj - xi)(yk - yi)
    xi, yi = pi[0], pi[1]
    xj, yj = pj[0], pj[1]
    xk, yk = pk[0], pk[1]
    
    (xk - xi)*(yj - yi) - (xj - xi)*(yk - yi)
  end
  
  def self.on_segment(pi, pj, pk)
    xi, yi = pi[0], pi[1]
    xj, yj = pj[0], pj[1]
    xk, yk = pk[0], pk[1]

    minx = [xi, xj].min
    maxx = [xi, xj].max
    miny = [yi, yj].min
    maxy = [yi, yj].max
    
    minx <= xk and xk <= maxx and miny <= yk and yk <= maxy
  end  
end

#pt1, pt2, pt3, pt4 = 
#puts Segments.intersect? [3,2], [2,1], [2,2], [1,2]
#puts Segments.intersect? [3,2], [2,1], [4,2], [1,2]
#puts Segments.intersect? [4,1], [1,1], [4,2], [1,2]
#puts Segments.intersect? [1,1], [2,2], [1,2], [2,1]
