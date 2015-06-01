require './player.rb'
require './player_turn.rb'
require './tree.rb'
require './circuit.rb'

class Game
	def initialize(grid)
		@grid = grid
		@firstPlayer = Player.new("Player 1", 'red')
		@secondPlayer = Player.new('Player 2', 'blue');
		@turn = :first
	end

	def accept_turn (dot)
		active_player.add_turn(PlayerTurn.new(Time.new, dot))

    seizure = get_seizure 
		if seizure != nil then
		  passive_player.each_turn do |turn|
		    seizure.contains_dot? turn.dot 
		  end
		end

    tree = tree_from_dot dot
    
    if tree.root.has_children? then
      max_square = 0
      best_circuit = nil
      tree.each_branch do |b| 
        circuit_dots = b.map {|n| n.data}.to_a
        circuit_dots.delete_at circuit_dots.length-1
        
        circuit = Circuit.new(circuit_dots)
        if circuit.is_meaningful? then
          possible_square = circuit.square
          if max_square < possible_square then
            max_square = possible_square
            best_circuit = circuit
          end
        end
      end		
      
      if best_circuit != nil then
        passive_player.reset_unavailable_dots
        active_player.reset_unavailable_dots
        
        seizures_to_delete = []
        passive_player.each_seizure {|s| seizures_to_delete << s if best_circuit.contains? s}
        seizures_to_delete.each {|s| passive_player.delete_seizure s} 
        
        active_player.add_seizure best_circuit

        captured_dots = 0
        passive_player.all_dots do |d|
          active_player.each_seizure do |s|
            if s.contains_dot? d then
              passive_player.make_dot_unavailable d
              captured_dots = captured_dots + 1
            end 
          end
        end    
        active_player.captured_dots_count = captured_dots 
        
        captured_dots = 0
        active_player.all_dots do |d|
          passive_player.each_seizure do |s|
            if s.contains_dot? d then
              active_player.make_dot_unavailable d
              captured_dots = 0
            end 
          end
        end
        passive_player.captured_dots_count = captured_dots 
        
      end
    end
	
		@turn = @turn == :first ? :second : :first
	end

	def active_player
		@turn == :first ? @firstPlayer : @secondPlayer
	end
	
	def passive_player
	  @turn == :first ? @secondPlayer : @firstPlayer  
	end

	def players
		[@firstPlayer, @secondPlayer]
	end

	def build_tree(tree_node, parent_node, dots_hash, circuits, dot)
    branch = TreeBranch.new(tree_node)
    if TreeBranchPathLookup.has_path? branch then
      branch.tail_node.cut if branch.head_node.data != branch.tail_node.data
      return
    end
	  
	  new_children = []

	  dot_neighbours = dot.neighbours.select{|d| @grid.contains? d and dots_hash.has_key? d}
	  neighbours = dot_neighbours #[]
	  
		for neighbour in neighbours 
			next if parent_node != nil and parent_node.data == neighbour
			
			new_children << tree_node.add_child(neighbour)
		end
		
		if new_children.empty? or neighbours.length == 1  then
      branch = TreeBranch.new(tree_node)
      if branch.head_node.data != branch.tail_node.data
        branch.tail_node.cut
      end
		else
		  for child_node in new_children
        build_tree(child_node, tree_node, dots_hash, circuits, child_node.data)
		  end
		end
	end	
	
	def tree_from_dot dot
	  puts "Tree for a dot: #{dot}"
		
    dots_hash = {}
    active_player.dots_not_in_circuits {|d| dots_hash[d] = true}
    
    seizures = []
    active_player.each_seizure {|s| seizures << s}
		
		tree = Tree.new(TreeItem.new(dot))
		build_tree(tree.root, nil, dots_hash, seizures, dot)

    tree
		#puts tree
	end
	
	def get_seizure
	  return nil
	  
		dotsHash = {}
		dotsArray = []
		active_player.eachTurn {|turn| dotsArray.push turn.dot}
		dotsArray.each {|dot| dotsHash[dot] = true}
		dot = dotsArray[dotsArray.length-1]
		puts "Start point #{dot}"
		pathes = pathes(dotsHash, dot, dot, {dot => dot})
		if pathes.length > 0 then
			puts "Pathes Found: #{pathes.length}"
				
			best_circuit = pathes.keys.map{|p| Circuit.new(p.keys)}.max_by {|c| c.square}
			puts "Square is #{best_circuit.square} for the best path #{best_circuit.dots}"
				
			return best_circuit
		end
		nil
	end
	
	def pathes(allDots, startDot, currentDot, pathDots)
		pathes = {}
		for neighbour in currentDot.neighbours.select{|d| @grid.contains? d} do
		  if neighbour.eql?(startDot) then
        pathes[pathDots] = pathDots if pathDots.length > 3 and Circuit.new(pathDots.keys).is_meaningful?
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

#require './grid.rb'
#require './player.rb'

#game = Game.new(Grid.new(5,5))
#game.acceptTurn(Dot.new(1,1))
#game.acceptTurn(Dot.new(1,2))
#game.acceptTurn(Dot.new(2,1))
#game.acceptTurn(Dot.new(3,2))
#game.acceptTurn(Dot.new(2,3))
#game.acceptTurn(Dot.new(3,3))

#game.tree

#STDIN.getc