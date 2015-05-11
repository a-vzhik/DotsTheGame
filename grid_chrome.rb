class GridChrome < Qt::GraphicsItem
	
	def initialize(grid, game)
		super(nil)
		setAcceptHoverEvents(true)
		
		@dot_radius = 4
		@grid = grid
		@game = game
		
		@bounding_rect = Qt::RectF.new(-300, -300, 600, 500)
		@background_color = Qt::Color.new('white')

		@margin = 10
		@grid_rect = Qt::RectF.new(
			boundingRect.left + @margin, 
			boundingRect.top + @margin, 
			boundingRect.width - 2*@margin, 
			boundingRect.height - 2*@margin) 

		@horizontal_gap = @grid_rect.width / (@grid.horizontalDotsCount - 1)
		@vertical_gap = @grid_rect.height / (@grid.verticalDotsCount - 1)

		@highlighted_dot = nil
	end		


	def paint(painter, arg, widget)
		# Body
		#painter.pen = Qt::Pen.new(Qt::Brush.new(Qt::Color.new('blue')), 2)
		painter.brush = Qt::Brush.new(@background_color)
		#painter.drawRect(boundingRect)

		painter.pen = Qt::Pen.new(Qt::Brush.new(Qt::Color.new('black')), 1)
		
    for step in 1..@grid.horizontalDotsCount do
			horizontal = @grid_rect.left + @horizontal_gap * (step - 1)
			painter.drawLine(horizontal, boundingRect.top, horizontal, boundingRect.bottom)
		end
		
		for step in 1..@grid.verticalDotsCount do
		  vertical = @grid_rect.top + @vertical_gap * (step - 1)
			painter.drawLine(boundingRect.left, vertical, boundingRect.right, vertical)
		end

		@grid.iterateDots do |dot| 
		  paint_dot painter, dot
		  #painter.drawText(coordinate(dot), "#{dot.horizontalIndex},#{dot.verticalIndex}")
    end

    for player in @game.players
      painter.brush = player.foreground
      player.unavailable_dots {|dot| paint_dot painter, dot}
    end
    
    for player in @game.players
      color = player.foreground.color
      
      painter.brush = Qt::Brush.new(Qt::Color.new(color.red, color.green, color.blue, 100))
      player.each_seizure do |s|
        points = Qt::Polygon.new(s.dots.map{|d| coordinate(d)}) 
        painter.drawPolygon(points)
      end
    end    

		painter.brush = @game.active_player.foreground
		paint_dot painter, @highlighted_dot if @highlighted_dot != nil

		for player in @game.players
			painter.brush = player.foreground
			player.available_dots {|dot| paint_dot painter, dot}
		end
		
	end

  def paint_dot (painter, dot)
    painter.drawEllipse(coordinate(dot), @dot_radius, @dot_radius)
  end

	def coordinate(dot)
		Qt::Point.new(
			@grid_rect.left + @horizontal_gap * dot.horizontalIndex, 
			@grid_rect.top + @vertical_gap * dot.verticalIndex)		
	end
	
	def square(dot)
		coord = coordinate (dot)
		Qt::RectF.new(coord.x-@dot_radius, coord.y-@dot_radius, @dot_radius*2, @dot_radius*2)
	end

	def hoverMoveEvent(event)
    @highlighted_dot = nil 

	  possible_row = ((event.pos().x - @grid_rect.left) / @horizontal_gap).round
	  possible_col = ((event.pos().y - @grid_rect.top) / @vertical_gap).round
	  
	  possible_dot = Dot.new(possible_row.floor, possible_col)
	  @highlighted_dot = possible_dot if square(possible_dot).contains(event.pos().x, event.pos().y)

		update boundingRect
	end

	def mousePressEvent(event)
		if event.button != Qt::LeftButton
			event.ignore
			return
		end

		@game.accept_turn(@highlighted_dot) if @highlighted_dot != nil and is_empty? @highlighted_dot
	end

  def is_empty? dot
    for player in @game.players
       return false if player.all_dots.select{|d| d == dot}.count > 0
    end
    
    true    
  end 

	def boundingRect
		@bounding_rect
	end

end