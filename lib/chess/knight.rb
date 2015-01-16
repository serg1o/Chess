module Chess
  class Knight < Piece
    attr_reader :hypo_moves
    def initialize(color)
      super
      @hypo_moves = [[2, 1], [2, -1], [1, 2], [1, -2], [-2, 1], [-2, -1], [-1, 2], [-1, -2]]
    end
  end
end
