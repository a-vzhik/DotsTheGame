class Dot
  include Comparable
  
	attr_reader :horizontalIndex, :verticalIndex 
	def initialize(horizontalIndex, verticalIndex)
		@horizontalIndex, @verticalIndex = horizontalIndex, verticalIndex
	end
	
  def neighbours
    neighbours = []
        
    topLeft = Dot.new(horizontalIndex-1, verticalIndex-1)
    neighbours.push topLeft 

    centerLeft = Dot.new(horizontalIndex-1, verticalIndex)
    neighbours.push centerLeft

    bottomLeft = Dot.new(horizontalIndex-1, verticalIndex+1)
    neighbours.push bottomLeft

    topCenter = Dot.new(horizontalIndex, verticalIndex-1)
    neighbours.push topCenter 

    bottomCenter = Dot.new(horizontalIndex, verticalIndex+1)
    neighbours.push bottomCenter
    
    topRight = Dot.new(horizontalIndex+1, verticalIndex-1)
    neighbours.push topRight 

    centerRight = Dot.new(horizontalIndex+1, verticalIndex)
    neighbours.push centerRight 

    bottomRight = Dot.new(horizontalIndex+1, verticalIndex+1)
    neighbours.push bottomRight 
  
    neighbours    
  end
	
	def eql?(other)
		self.class == other.class and horizontalIndex == other.horizontalIndex and verticalIndex == other.verticalIndex
	end 

	def hash
		horizontalIndex.hash ^ verticalIndex.hash
	end

  def <=> (other)
     return -1 if verticalIndex < other.verticalIndex 
     return -1 if verticalIndex == other.verticalIndex and horizontalIndex < other.horizontalIndex
     return 0 if verticalIndex == other.verticalIndex and horizontalIndex == other.horizontalIndex
     return 1
  end
  
	def to_s
		default = super
		default + "(#{horizontalIndex}, #{verticalIndex})"
	end
	
	def to_a
	  [@horizontalIndex, @verticalIndex]
	end
end


