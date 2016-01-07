require_relative './dot.rb'
require_relative './segment.rb'

class Circuit

  attr_reader :dots

  def initialize(dots)
    @dots = DotCollection.new(dots)
  end

  def self.load (str)
    dots = str.split('),').map do |point_str|
      match_data = point_str.match(/(\d+), (\d+)/)
      Dot.new(match_data[1].to_i, match_data[2].to_i)
    end

    Circuit.new(dots)
  end

  def square
    firstSum, secondSum = 0.0, 0.0
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
    circuit.dots.all? do |d|
      contains_dot? d or has_dot? d
    end
  end

  def has_dot? (dot)
    @dots.contains? dot
  end

  def contains_dot? (dot)
    return false if has_dot? dot

    cuts = (0...@dots.length)
      .map {|i| Segment.new(@dots[i-1], @dots[i])}
      .select {|cut| cut.is_vertical? and cut.same_vertical? dot}

    return false if cuts.length < 4

    cut_pairs = (0...cuts.length).map {|i| [cuts[i-1], cuts[i]]}
    left_ray = Segment.new(Dot.new(-1, dot.verticalIndex), dot)
    cut_pairs.select{|pair| ray_intersects_two_segments?(left_ray, pair[0], pair[1])}.count.odd?
  end

  def ray_intersects_two_segments? (ray, first_segment, second_segment)
    first_cut_intersects = first_segment.intersects? ray
    second_cut_intersects = second_segment.intersects? ray
    acute_angle = first_segment.begin_point.verticalIndex == second_segment.end_point.verticalIndex

    first_cut_intersects and second_cut_intersects and !acute_angle
  end

  def to_s
    @dots.to_s
  end
end
=begin
c1 = Circuit.load('(4, 2), (5, 3), (5, 4), (5, 5), (4, 4), (3, 5), (3, 4), (3, 3)')
puts c1.contains_dot?(Dot.new(4,5))


c1 = Circuit.load('(6, 6), (6, 7), (5, 8), (6, 9), (7, 10), (8, 9), (9, 8), (8, 7), (7, 7)')
c2 = Circuit.load('(3, 4), (4, 3), (5, 4), (6, 5), (6, 6), (7, 7), (8, 7), (9, 8), (8, 9), (7, 10), (6, 11), (5, 11), (4, 10), (3, 9), (2, 10), (1, 9), (1, 8), (2, 7), (2, 6), (3, 5)')

puts c2.contains? c1

c1 = Circuit.load('(3, 10), (4, 11), (5, 12), (6, 12), (6, 11), (7, 10), (8, 10), (9, 9), (9, 8), (9, 7), (8, 6), (7, 7), (6, 8), (5, 9), (4, 10), (3, 9), (3, 8), (2, 7), (1, 8), (1, 9), (2, 10)')
c2 = Ciruit.load('(9, 10), (9, 9), (9, 8), (9, 7), (8, 6), (7, 7), (6, 8), (5, 9), (4, 10), (3, 9), (3, 8), (2, 7), (1, 8), (1, 9), (2, 10), (3, 10), (4, 11), (5, 12), (6, 11), (7, 10), (8, 10)')

puts c1.contains? c2

=end

#c1 = Circuit.load('(3, 10), (4, 11), (5, 12), (6, 12), (6, 11), (7, 10), (8, 10), (9, 9), (9, 8), (9, 7), (8, 6), (7, 7), (6, 8), (5, 9), (4, 10), (3, 9), (3, 8), (2, 7), (1, 8), (1, 9), (2, 10)')
#c2 = Circuit.load('(9, 10), (9, 9), (9, 8), (9, 7), (8, 6), (7, 7), (6, 8), (5, 9), (4, 10), (3, 9), (3, 8), (2, 7), (1, 8), (1, 9), (2, 10), (3, 10), (4, 11), (5, 12), (6, 11), (7, 10), (8, 10)')

#puts c2.contains? c1
