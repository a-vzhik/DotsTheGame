require 'thread'
require 'Qt'

require './game.rb'
require './grid.rb'
require './grid_chrome.rb'

app = Qt::Application.new(ARGV)

scene =  Qt::GraphicsScene.new
scene.setSceneRect(-300, -300, 600, 500)
#scene.setBackgroundBrush(Qt::Brush.new(Qt::Color.new('lightgreen')))
scene.itemIndexMethod = Qt::GraphicsScene::NoIndex

grid = Grid.new(15, 15)
game = Game.new(grid)
gridChrome = GridChrome.new(grid, game)

scene.addItem(gridChrome)

view = Qt::GraphicsView.new(scene)
view.renderHint = Qt::Painter::Antialiasing
view.backgroundBrush = Qt::Brush.new(Qt::Color.new('lightgray'))
view.cacheMode = Qt::GraphicsView::CacheBackground
#view.dragMode = Qt::GraphicsView::ScrollHandDrag
view.setWindowTitle(QT_TRANSLATE_NOOP(Qt::GraphicsView, "Dots"))
view.resize(800, 600)
view.show

app.exec
