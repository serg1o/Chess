class Player
  attr_reader :color, :order_player, :computer_player
  attr_accessor :queen_rook_moved, :king_rook_moved, :king_moved
  def initialize(color, order)
    @order_player = order #player1, player2
    @color = color
  end
end