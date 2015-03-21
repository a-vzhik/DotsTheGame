class GridChrome < Qt::GraphicsItem
	
	def initialize(grid, game)
		super(nil)
		setAcceptHoverEvents(true)
		
		@grid = grid
		@game = game
		
		@boundingRect = Qt::RectF.new(-300, -300, 600, 500)
		@backgroundColor = Qt::Color.new('lightgreen')

		@margin = 10
		@gridRect = Qt::RectF.new(
			boundingRect.left + @margin, 
			boundingRect.top + @margin, 
			boundingRect.width - 2*@margin, 
			boundingRect.height - 2*@margin) 

		@horizontalGap = @gridRect.width / (@grid.horizontalDotsCount - 1)
		@verticalGap = @gridRect.height / (@grid.verticalDotsCount - 1)

		@highlightedDot = nil
	end		


	def paint(painter, arg, widget)
		# Body
		painter.pen = Qt::Pen.new(Qt::Brush.new(Qt::Color.new('blue')), 2)
		painter.brush = Qt::Brush.new(@backgroundColor)
		painter.drawRect(boundingRect)

		painter.pen = Qt::Pen.new(Qt::Brush.new(Qt::Color.new('black')), 1)
		

                for step in 1..@grid.horizontalDotsCount do
			horizontal = @gridRect.left + @horizontalGap * (step - 1)
			painter.drawLine(horizontal, boundingRect.top, horizontal, boundingRect.bottom)
		end
                for step in 1..@grid.verticalDotsCount do
                        vertical = @gridRect.top + @verticalGap * (step - 1)
			painter.drawLine(boundingRect.left, vertical, boundingRect.right, vertical)
		end

		@grid.iterateDots { |dot| painter.drawEllipse(coordinate(dot), 3, 3) }

		painter.brush = @game.activePlayer.foreground
		painter.drawEllipse(coordinate(@highlightedDot), 3, 3) if @highlightedDot != nil

		for player in @game.players
			painter.brush = player.foreground
			player.eachTurn {|turn| painter.drawEllipse(coordinate(turn.dot), 3, 3)}
		end
		
	end

	def coordinate(dot)
		Qt::Point.new(
			@gridRect.left + @horizontalGap * dot.horizontalIndex, 
			@gridRect.top + @verticalGap * dot.verticalIndex)		
	end

	
	def square(dot)
		coord = coordinate (dot)
		Qt::RectF.new(coord.x-3, coord.y-3, 6, 6)
	end

	def hoverMoveEvent(event)
		@highlightedDot = nil 
		@grid.iterateDots do |dot|
			@highlightedDot = dot if square(dot).contains(event.pos().x, event.pos().y)			
			break if @highlightedDot != nil
		end

		update boundingRect
	end

	def mousePressEvent(event)
		if event.button != Qt::LeftButton
			event.ignore
			return
		end

		@game.acceptTurn(@highlightedDot) if @highlightedDot != nil
	end

	def boundingRect
		@boundingRect
	end

end