require './player.rb'
require './player_turn.rb'

class Tree
	attr_reader :root
	
	def initialize (root)
		@root = root
	end
	
	def to_s
		@root.to_s
	end
end

class TreeItem
	attr_reader :children, :parent, :data
	
	def initialize (data, parent = nil)
		@children = []
		@data = data
		@parent = parent
	end
	
	def add_child (data)
		child = TreeItem.new(data, self)
		@children.push child 
		child
	end
	
	def branch
		TreeBranch.new(self)
	end
	
	def to_s
		branch_str = ''
		if @children.length == 0 then
			count = 0 
			TreeBranch.new(self).traverse do |node|
				branch_str = node.data.to_s + " -> " + branch_str
				count = count + 1
			end
			branch_str = branch_str + "\n"
			branch_str = '' if count <=4
		else
			for child in children 
				child_str = child.to_s 
				branch_str = branch_str + child_str if child_str != ''
			end
		end
		branch_str
	end
end

class TreeBranch

	def initialize(start_node)
		@start_node = start_node
	end
	
	def traverse (&block)
		node = @start_node
		while node != nil 
			block.call node
			node = node.parent
		end
	end
end

class TreeBranchPathLookup
	def self.has_path?(branch)
		hash = {}
		branch.traverse do |node|
			return true if hash.has_key? node.data
			hash[node.data] = true
		end
		false
	end
end

class Game
	def initialize(grid)
		@grid = grid
		@firstPlayer = Player.new('Player 1', 'red')
		@secondPlayer = Player.new('Player 2', 'blue');
		@turn = :first
	end

	def acceptTurn (dot)
		activePlayer.addTurn(PlayerTurn.new(Time.new, dot))

		#seizure?
		
		#@turn = @turn == :first ? :second : :first
	end

	def activePlayer
		@turn == :first ? @firstPlayer : @secondPlayer
	end

	def players
		[@firstPlayer, @secondPlayer]
	end

	def build_tree(tree_node, dots_hash, dot)
		for neighbour in neighbours(dot) 
			next if !dots_hash.has_key? neighbour 
			
			child_node = tree_node.add_child neighbour
			
			if !TreeBranchPathLookup.has_path? (TreeBranch.new(child_node)) then
				build_tree(child_node, dots_hash, child_node.data)
			end
		end
	end	
	
	def tree
		dots_hash = {}
		activePlayer.eachTurn {|turn| dots_hash[turn.dot] = turn.dot}
		
		dots_hash.each_key do |dot|
			puts "Tree for a dot: #{dot}"
		
			tree = Tree.new(TreeItem.new(dot))
			build_tree(tree.root, dots_hash, dot)

			puts tree
		end
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

require './grid.rb'
require './player.rb'

game = Game.new(Grid.new(5,5))
game.acceptTurn(Dot.new(1,1))
game.acceptTurn(Dot.new(1,2))
game.acceptTurn(Dot.new(2,1))
game.acceptTurn(Dot.new(3,2))
game.acceptTurn(Dot.new(2,3))
game.acceptTurn(Dot.new(3,3))

game.tree

STDIN.getc