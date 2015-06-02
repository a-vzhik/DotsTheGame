require './dot.rb'

class Grid
  attr_reader :horizontalDotsCount, :verticalDotsCount

  def initialize(horizontalDotsCount, verticalDotsCount)
    @horizontalDotsCount, @verticalDotsCount = horizontalDotsCount, verticalDotsCount
  end

  def iterateDots
    return if !block_given?

    for i in 1..horizontalDotsCount
      for j in 1..verticalDotsCount
        yield Dot.new(i-1, j-1)
      end
    end
  end

  def contains?(dot)
    dot.horizontalIndex >= 0 and dot.verticalIndex >= 0 and dot.horizontalIndex < horizontalDotsCount and dot.verticalIndex < verticalDotsCount
  end
end