require 'thread'
require 'Qt'
require 'json'

require_relative './qt_extensions.rb'
require_relative './server.rb'
require_relative './client.rb'
require_relative './game.rb'
require_relative './grid.rb'
require_relative './hot_seat_game_model.rb'
require_relative './grid_chrome.rb'
require_relative './hot_seat_game_controller.rb'
require_relative './socket_game_controller.rb'
require_relative './start_view.rb'
require_relative './tab_control.rb'
require_relative './game_view.rb'
require_relative './local_network_game_start_view.rb'
require_relative './local_network_game_start_view.rb'
require_relative './player_settings.rb'
require_relative './player_chrome.rb'

app = Qt::Application.new(ARGV)

#font_id = Qt::FontDatabase.addApplicationFont("PressStart2P.ttf")
font_id = Qt::FontDatabase.addApplicationFont("Pixel LCD-7.ttf")

families = Qt::FontDatabase.applicationFontFamilies(font_id)
font = Qt::Font.new(families[0])
font.setPointSize 10
app.setFont font
icon = Qt::Icon.new('trash.svg')
#puts icon.availableSizes.count
app.setWindowIcon icon


TabControl.new.show

app.exec
