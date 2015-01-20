module Chess
  class Piece
    attr_reader :color
    attr_accessor :possible_moves
    def initialize(color)
      @color = color
      @possible_moves = Array.new
    end
  end
end
