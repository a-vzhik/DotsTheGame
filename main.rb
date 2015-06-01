require 'thread'
require 'Qt'

require './qt_extensions.rb'
require './game.rb'
require './grid.rb'
require './grid_chrome.rb'
require './start_view.rb'
require './tab_control.rb'
require './game_view.rb'
require './player_chrome.rb'

app = Qt::Application.new(ARGV)

#font_id = Qt::FontDatabase.addApplicationFont("PressStart2P.ttf")
font_id = Qt::FontDatabase.addApplicationFont("Pixel LCD-7.ttf")

families = Qt::FontDatabase.applicationFontFamilies(font_id)
font = Qt::Font.new(families[0])
font.setPointSize 10
app.setFont font

TabControl.new.show

app.exec
