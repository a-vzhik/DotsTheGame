class PlayerTurn
  attr_reader :time, :dot

  def initialize(time, dot)
    @time, @dot = time, dot
  end
end