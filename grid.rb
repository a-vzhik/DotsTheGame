class Grid
  attr_reader :horizontalDotsCount, :verticalDotsCount, :empty_dots

  def initialize(horizontalDotsCount, verticalDotsCount)
    @horizontalDotsCount, @verticalDotsCount = horizontalDotsCount, verticalDotsCount

    @empty_dots = DotCollection.new
    iterate_dots {|d| @empty_dots.add (d)}
  end

  def delete_empty_dot(dot)
    @empty_dots.delete(dot)
  end

  def contains?(dot)
    dot.horizontalIndex >= 0 and dot.verticalIndex >= 0 and dot.horizontalIndex < horizontalDotsCount and dot.verticalIndex < verticalDotsCount
  end

  def iterate_dots
    return if !block_given?

    for i in 1..horizontalDotsCount
      for j in 1..verticalDotsCount
        yield Dot.new(i-1, j-1)
      end
    end
  end

  private :iterate_dots
end