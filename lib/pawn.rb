require "piece"
class Pawn < Piece
  attr_accessor :hypo_moves, :enpassant_move
  def initialize(color)
    super color
    @hypo_moves = color == BLACK ? [[0, 1], [0, 2], [1, 1], [-1, 1]] : [[0, -1], [0, -2], [-1, -1], [1, -1]]
    @enpassant_move = Array.new
  end
end
