class PlayerSettings
  attr_reader :dot_stroke, :dot_fill, :transparent_dot_fill, :capture_fill

  def initialize (player_id, filename)
    json = JSON.parse(File.read(filename), {:symbolize_names => true})
    #json = JSON.parse('{}')

    player_settings = json[:players_settings].select{|s| s[:player_id] == player_id}.first
    @dot_stroke = Qt::Brush.new(Qt::Color.fromString(player_settings[:dot_stroke]))
    @dot_fill = Qt::Brush.new(Qt::Color.fromString(player_settings[:dot_fill]))
    @transparent_dot_fill = Qt::Brush.new(Qt::Color.fromString(player_settings[:dot_fill]).makeTransparent)
    @capture_fill = Qt::Brush.new(Qt::Color.fromString(player_settings[:capture_fill]))
  end
end