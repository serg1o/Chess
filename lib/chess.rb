require "yaml"
module Chess
  BLACK = "black"
  WHITE = "white"
  UNICODE = {"b_R" => "\u265c", "b_N" => "\u265e", "b_B" => "\u265d", "b_Q" => "\u265b", "b_K" => "\u265a", "b_P" => "\u265f", "w_R" => "\u2656", "w_N" => "\u2658", "w_B" => "\u2657", "w_Q" => "\u2655", "w_K" => "\u2654", "w_P" => "\u2659"}
  TABLE_LINES = {
    v_l_join: "\u251c",
    mid_join: "\u253c", 
    v_r_join: "\u2524", 
    mid_top_join: "\u252c", 
    mid_bot_join: "\u2534", 
    l_t_corner: "\u250c", 
    r_t_corner: "\u2510", 
    l_b_corner: "\u2514", 
    r_b_corner: "\u2518", 
    v_line: "\u2502", 
    h_line: "\u2500"
  }
  SCORES = { "Queen" => 9, "Rook" => 5, "Bishop" => 3, "Knight" => 3, "Pawn" => 1 }
  library = %i[ Player Piece Rook Pawn King Queen Bishop Knight Board Game  ]
  library.each {  |class| autoload class, "chess/#{class.to_s.downcase}"  }

end
