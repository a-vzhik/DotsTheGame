class Circuit
  attr_reader :dots
  def initialize(dots)
    @dots = dots
  end
  
  def square
    firstSum,secondSum = 0,0
    lastIndex = @dots.length-1
    for i in 1..lastIndex
      firstSum += @dots[i-1].horizontalIndex * @dots[i].verticalIndex
      secondSum += @dots[i-1].verticalIndex * @dots[i].horizontalIndex
    end
    
    firstSum += @dots[lastIndex].horizontalIndex * @dots[0].verticalIndex
    secondSum += @dots[lastIndex].verticalIndex * @dots[0].horizontalIndex
  
    ((firstSum - secondSum) / 2).abs    
  end
  
  def is_meaningful?
    max_hi = @dots.max_by {|dot| dot.horizontalIndex}.horizontalIndex
    min_hi = @dots.min_by {|dot| dot.horizontalIndex}.horizontalIndex
    max_vi = @dots.max_by {|dot| dot.verticalIndex}.verticalIndex
    min_vi = @dots.min_by {|dot| dot.verticalIndex}.verticalIndex
    
    (max_hi - min_hi >= 2) and (max_vi - min_vi >= 2) 
  end
  
  def contains_dot? (dot)
    count = 0
    cuts = []
    for i in 1...@dots.length
       next if @dots[i-1].verticalIndex == @dots[i].verticalIndex 
       if @dots[i-1].verticalIndex == dot.verticalIndex or @dots[i].verticalIndex == dot.verticalIndex then
         cuts << [@dots[i-1], @dots[i]] #p3, p4 
       end
    end   
    
    for cut in cuts
      ray_cut = [Dot.new(-1, dot.verticalIndex), dot] #p1, p2
      
      y4 = cut[1].verticalIndex
      y3 = cut[0].verticalIndex
      y2 = ray_cut[1].verticalIndex
      y1 = ray_cut[0].verticalIndex
      
      x4 = cut[1].horizontalIndex
      x3 = cut[0].horizontalIndex
      x2 = ray_cut[1].horizontalIndex
      x1 = ray_cut[0].horizontalIndex
      
      div = ((y4 - y3)*(x2 - x1) - (x4 - x3)*(y2 - y1))
      ua = ((x4 - x3)* (y1 - y3) - (y4 - y3)*(x1 - x3)) / div
      ub = ((x2 - x1)*(y1 - y3) - (y2 - y1)*(x1 - x3)) / div
      
      if ((0..1).include? ua) and ((0..1).include? ub) then
        x = ray_cut[0].horizontalIndex + ua * (ray_cut[1].horizontalIndex - ray_cut[0].horizontalIndex)
        y = ray_cut[0].verticalIndex + ua * (ray_cut[1].verticalIndex - ray_cut[0].horizontalIndex)
        puts "Cuts #{cut} and #{ray_cut} intersects at (#{x}; #{y})"
        count = count+1
      end
    end
    count.odd?  
  end
  
  def to_s
    @dots.to_s
  end
end