class Piece
  attr_reader :color
  attr_accessor :possible_moves
  def initialize(color)
    @color, possible_moves = color, Array.new
  end
end
