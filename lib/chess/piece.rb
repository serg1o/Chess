module Chess
  class Piece
    attr_reader :color
    attr_accessor :possible_moves, :moved
    def initialize color
      @moved, @color, @possible_moves = false, color, Array.new
    end
  end
end
