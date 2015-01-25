module Chess
  class Piece
    attr_reader :color
    attr_accessor :possible_moves, :moved
    def initialize(color)
      @moved = false
      @color = color
      @possible_moves = Array.new
    end
  end
end
