module Chess
  class King < Piece
    attr_reader :hypo_moves
    def initialize(color)
      super
      @hypo_moves = [[0, -1], [0, 1], [1, -1], [1, 1], [1, 0], [-1, -1], [-1, 1], [-1, 0]]
    end
  end
end
