class Player
	attr_reader :name
	def initialize(name, color)
		@name = name
		@turns = []
		@foreground = nil
		@color = color
		@unavailable_dots = {}
		@seizures = []
	end

	def add_turn(turn)
		puts turn
		@turns.push(turn)		
	end

  def foreground
    if @foreground == nil then 
      @foreground = Qt::Brush.new(Qt::Color.new(@color))     
    end
    @foreground
  end

	def each_turn
		return @turns if !block_given?
		
		for turn in @turns
			yield turn
		end
	end

	def all_dots
	  enum = each_turn.map{|t| t.dot}
	  if block_given? then
	    enum.each{|dot| yield dot }
	  else
	    enum
	  end 
	  
	end	
	
	def available_dots
	  each_turn{|t| yield t.dot if is_available t.dot} if block_given?
	end
	
	def unavailable_dots
	  each_turn{|t| yield t.dot if !is_available t.dot} if block_given?
	end
	
	def is_available (dot)
	  !@unavailable_dots.has_key? dot
	end
	
	def make_dot_unavailable (dot)
	  @unavailable_dots[dot] = dot
	end  
	
	def add_seizure (seizure)
	  @seizures.reject! do |s|
	    seizure.contains? s
	  end
	  
	  @seizures << seizure
	end
	
	def each_seizure
	  @seizures.each {|s| yield s} if block_given?
	end
end