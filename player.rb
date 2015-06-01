class Player
	attr_reader :name
	attr_accessor :captured_dots_count
	def initialize(name, color)
		@name = name
		@turns = []
		@foreground = nil
		@color = color
		@unavailable_dots = {}
		@dots_inside_circuits = {}
	 
		@seizures = []
		@captured_dots_count = 0
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
	
	def dots_not_in_circuits
	  #each_turn{|t| yield t.dot if is_available t.dot and !is_dot_in_circuit t.dot} if block_given?
	  each_turn{|t| yield t.dot if is_available t.dot and !@dots_inside_circuits.has_key? t.dot} if block_given?
	end
	
	def is_dot_in_circuit (dot)
	  @seizures.any? {|s| s.has_dot? dot}
	end
	
	def is_available (dot)
	  !@unavailable_dots.has_key? dot
	end
	
	def make_dot_unavailable (dot)
	  @unavailable_dots[dot] = dot
	end  
	
	def unavailable_dot_count
	  @unavailable_dots.count;
	end
	
	def reset_unavailable_dots
	  @unavailable_dots = {}
	end
	
	def add_seizure (seizure)
	  @seizures.reject! do |s|
	    seizure.contains? s
	  end
	  
	  available_dots do |d| 
	    if seizure.contains_dot? d and !seizure.has_dot? d then
	      @dots_inside_circuits[d] = d
	    end
	  end
	  
	  @seizures << seizure
	end
	
	def delete_seizure (seizure)
	  @seizures.delete seizure
	end
	
	def each_seizure
	  @seizures.each {|s| yield s} if block_given?
	end
end