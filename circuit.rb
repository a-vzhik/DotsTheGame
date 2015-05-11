require './dot.rb'
require './cut.rb'

class Circuit
  attr_reader :dots
  def initialize(dots)
    @dots = dots
    @dots_hash = Hash[@dots.map{|d| [d, true]}]
  end
  
  def neighbours
    ary = @dots.map{|dot| dot.neighbours}.flatten.map{|n| [n, true]}
    hash = Hash[@dots.map{|dot| dot.neighbours}.flatten.map{|n| [n, true]}]
    hash.reject{|dot, v| contains_dot? dot}.keys
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
  
  def contains? (circuit)
    circuit.dots.all? {|d| contains_dot? d or has_dot? d}
  end
  
  def has_dot? (dot)
    @dots_hash.has_key? dot
  end
  
  def contains_dot? (dot)
    count = 0
    cuts = [Segment.new(@dots.last, @dots.first)]
    for i in 1...@dots.length
       next if @dots[i-1].verticalIndex == @dots[i].verticalIndex 
       if @dots[i-1].verticalIndex == dot.verticalIndex or @dots[i].verticalIndex == dot.verticalIndex then
         cuts << Segment.new(@dots[i-1], @dots[i])
       end
    end   
    
    right_ray = Segment.new(Dot.new(100, dot.verticalIndex), dot)
    for cut in cuts
      count = count + 1 if cut.intersects? right_ray 
    end 
    
    return false if count != 2
    
    left_ray = Segment.new(Dot.new(-1, dot.verticalIndex), dot)
    for cut in cuts
      count = count + 1 if cut.intersects? left_ray
    end     
    count == 4
  end
 
  def to_s
    @dots.to_s
  end
end

circ = Circuit.new([Dot.new(5,5), Dot.new(4,6), Dot.new(5,7), Dot.new(6,6)]) 
nbrs = circ.neighbours 

puts nbrs.to_s
