class Player
	attr_reader :name
	def initialize(name, color)
		@name = name
		@turns = []
		@foreground = nil
		@color = color
	end

	def addTurn(turn)
		puts turn
		@turns.push(turn)		
	end

  def foreground
    if @foreground == nil then 
      @foreground = Qt::Brush.new(Qt::Color.new(@color))     
    end
    @foreground
  end

	def eachTurn
		return if !block_given?
		
		for turn in @turns
			yield turn
		end
	end
		
end