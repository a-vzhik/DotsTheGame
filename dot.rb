class Dot
  include Comparable
  
	attr_reader :horizontalIndex, :verticalIndex 
	def initialize(horizontalIndex, verticalIndex)
		@horizontalIndex, @verticalIndex = horizontalIndex, verticalIndex
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
end


