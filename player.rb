class Player
	attr_reader :name, :foreground
	def initialize(name, color)
		@name = name
		@foreground = Qt::Brush.new(Qt::Color.new(color))
		@turns = []
	end

	def addTurn(turn)
		puts turn
		@turns.push(turn)		
	end


	def eachTurn
		return if !block_given?
		
		for turn in @turns
			yield turn
		end
	end
	
end