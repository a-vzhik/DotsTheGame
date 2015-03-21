require './player.rb'
require './player_turn.rb'

class Game
	def initialize(grid)
		@grid = grid
		@firstPlayer = Player.new('Player 1', 'red')
		@secondPlayer = Player.new('Player 2', 'blue');
		@turn = :first
	end

	def acceptTurn (dot)
		activePlayer.addTurn(PlayerTurn.new(Time.new, dot))

		seizure?
		
		#@turn = @turn == :first ? :second : :first
	end

	def activePlayer
		@turn == :first ? @firstPlayer : @secondPlayer
	end

	def players
		[@firstPlayer, @secondPlayer]
	end

	def seizure?
		dotsHash = {}
		dotsArray = []
		activePlayer.eachTurn {|turn| dotsArray.push turn.dot}
		dotsArray.sort!
		dotsArray.each {|dot| dotsHash[dot] = true}
		dotsArray.each do |dot|
		  puts "Start point #{dot}"
			pathes = pathes(dotsHash, dot, dot, {dot => dot})
			if pathes.length > 0 then
				puts "Pathes Found: #{pathes.length}"
				
				bestPath = pathes.keys.max_by {|p| square(p.keys)}
        puts "Square is #{square(bestPath.keys)} for the best path #{bestPath.keys}"
				
				#return pathes[0]
			end
		end
		nil
	end
	
	def square(dots)
	  firstSum,secondSum = 0,0
	  lastIndex = dots.length-1
    for i in 1..lastIndex
	    firstSum += dots[i-1].horizontalIndex * dots[i].verticalIndex
	    secondSum += dots[i-1].verticalIndex * dots[i].horizontalIndex
	  end
	  
    firstSum += dots[lastIndex].horizontalIndex * dots[0].verticalIndex
    secondSum += dots[lastIndex].verticalIndex * dots[0].horizontalIndex
  
    ((firstSum - secondSum) / 2).abs
	end
	
	def pathes(allDots, startDot, currentDot, pathDots)
		pathes = {}
		for neighbour in neighbours(currentDot) do
		  if neighbour.eql?(startDot) then
        pathes[pathDots] = pathDots if pathDots.length > 3
      end 
      
		  next if pathDots.has_key? neighbour
		  
			if allDots.has_key? neighbour then
			  newPath = pathDots.clone
				newPath[neighbour] = neighbour
        			
				pathes(allDots, startDot, neighbour, newPath).each_key {|p| pathes[p] = p if p.length > 3} 
			end
		end			
		pathes
	end

	def neighbours(dot)
		neighbours = []
		
		topLeft = Dot.new(dot.horizontalIndex-1, dot.verticalIndex-1)
		neighbours.push topLeft if @grid.contains? topLeft

		centerLeft = Dot.new(dot.horizontalIndex-1, dot.verticalIndex)
		neighbours.push centerLeft if @grid.contains? centerLeft

		bottomLeft = Dot.new(dot.horizontalIndex-1, dot.verticalIndex+1)
		neighbours.push bottomLeft if @grid.contains? bottomLeft

		topCenter = Dot.new(dot.horizontalIndex, dot.verticalIndex-1)
		neighbours.push topCenter if @grid.contains? topCenter

		bottomCenter = Dot.new(dot.horizontalIndex, dot.verticalIndex+1)
		neighbours.push bottomCenter if @grid.contains? bottomCenter

		topRight = Dot.new(dot.horizontalIndex+1, dot.verticalIndex-1)
		neighbours.push topRight if @grid.contains? topRight

		centerRight = Dot.new(dot.horizontalIndex+1, dot.verticalIndex)
		neighbours.push centerRight if @grid.contains? centerRight

		bottomRight = Dot.new(dot.horizontalIndex+1, dot.verticalIndex+1)
		neighbours.push bottomRight if @grid.contains? bottomRight
	
		neighbours
	end
end