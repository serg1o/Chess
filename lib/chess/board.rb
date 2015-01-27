module Chess
  class Board
    attr_accessor :squares, :last_selected_piece, :recent_moves
    def initialize
      @squares = Array.new(8) { Array.new(8) }
      @last_selected_piece = nil
    end

    def squares_iterator
      (0..7).each do |x|
        (0..7).each {|y| yield x, y}
      end
    end

    def create_pieces
      (0..7).each {|pos| @squares[pos][1] = Pawn.new(BLACK)}
      (0..7).each {|pos| @squares[pos][6] = Pawn.new(WHITE)}
      @squares[0][0] = Rook.new(BLACK)
      @squares[7][0] = Rook.new(BLACK)
      @squares[0][7] = Rook.new(WHITE)
      @squares[7][7] = Rook.new(WHITE)
      @squares[1][0] = Knight.new(BLACK)
      @squares[6][0] = Knight.new(BLACK)
      @squares[1][7] = Knight.new(WHITE)
      @squares[6][7] = Knight.new(WHITE)
      @squares[2][0] = Bishop.new(BLACK)
      @squares[5][0] = Bishop.new(BLACK)
      @squares[2][7] = Bishop.new(WHITE)
      @squares[5][7] = Bishop.new(WHITE)
      @squares[3][0] = Queen.new(BLACK)
      @squares[3][7] = Queen.new(WHITE)
      @squares[4][0] = King.new(BLACK)
      @squares[4][7] = King.new(WHITE)
    end

    def get_board_signature
       @squares.flatten.each_with_index.inject("") { |res, (piece, index)| res += piece.nil? ? "" : get_piece_code(piece) + index.to_s }
    end

    def line_moves(origin_x, origin_y, inc_x, inc_y, start_square, direction)
      moves, i, j = Array.new, direction * inc_x, direction * inc_y
      loop do
        new_x, new_y = origin_x + i, origin_y + j
        break unless new_x.between?(0, 7) && new_y.between?(0, 7)
        square = squares[new_x][new_y]
        unless square.nil?
          moves.push [new_x, new_y] unless square.color == start_square.color
          break
        end
        moves.push [new_x, new_y]
        i += direction * inc_x
        j += direction * inc_y
      end
      return moves
    end

    def get_line_moves(origin_x, origin_y, inc_x, inc_y, start_square)
      line_moves(origin_x, origin_y, inc_x, inc_y, start_square, 1) + line_moves(origin_x, origin_y, inc_x, inc_y, start_square, -1)
    end

    def find_possible_moves_pawn(piece, position_x, position_y)
      result = Array.new
      piece.hypo_moves.each do |hm|
        x, y = position_x + hm[0], position_y + hm[1]
        next unless (x.between?(0, 7) && y.between?(0, 7))
        if squares[x][y].nil? && hm[0].zero?
          result.push([x, y]) if hm[1].abs == 1 || (squares[x][y - 1].nil? && hm[1] == 2 && piece.color == BLACK) || ((squares[x][y + 1].nil?) && (hm[1] == -2) && (piece.color == WHITE))
        end
        result.push [x, y] if (squares[x][y] != nil) && (squares[x][y].color != piece.color) && (hm[0] != 0)
      end
      result.push piece.enpassant_move unless piece.enpassant_move.empty?
      piece.possible_moves = result
    end

    def find_possible_moves_rook(piece, position_x, position_y)
      piece.possible_moves = get_line_moves(position_x, position_y, 1, 0, piece) + get_line_moves(position_x, position_y, 0, 1, piece)
    end

    def find_possible_moves_bishop(piece, position_x, position_y)
      piece.possible_moves = get_line_moves(position_x, position_y, 1, 1, piece) + get_line_moves(position_x, position_y, 1, -1, piece)
    end

    def find_possible_moves_generic(piece, position_x, position_y)
      result = Array.new
      piece.hypo_moves.each do |hm|
        x, y = position_x + hm[0], position_y + hm[1]
        result.push [x, y] if (x.between?(0, 7) && y.between?(0, 7) && ((squares[x][y] == nil) || (squares[x][y].color != piece.color)))
      end
      piece.possible_moves = result
    end

    def find_possible_moves_queen(piece, x, y)
      piece.possible_moves = find_possible_moves_bishop(piece, x, y) + find_possible_moves_rook(piece, x, y)
    end

    def find_possible_moves(piece, x, y)
      case piece
        when Pawn then find_possible_moves_pawn piece, x, y 
        when Rook then find_possible_moves_rook piece, x, y 
        when Bishop then find_possible_moves_bishop piece, x, y 
        when Queen then find_possible_moves_queen piece, x, y 
        else # "King" or "Knight"
          find_possible_moves_generic piece, x, y 
      end
    end

    def find_king_coordinates(player) 
      squares_iterator {|x, y| return [x, y] if (!squares[x][y].nil? && (squares[x][y].class == Chess::King) && (player.color == squares[x][y].color))}
    end

    def in_check?(player, position = nil) #check if player is in check
      position ||= find_king_coordinates(player)
      squares_iterator do |x, y|
        next if squares[x][y].nil? || player.color == squares[x][y].color
        poss_moves = find_possible_moves squares[x][y], x, y
        return true if poss_moves.include? position
      end
      false
    end

    def make_move(from, to, piece_to_restore = nil)
      piece_to_move, piece_taken = squares[from[0]][from[1]], nil
      if piece_to_move.class == Pawn && (piece_to_move.enpassant_move == from || piece_to_move.enpassant_move == to)
        inc_y = (piece_to_move.color == WHITE) ? 1 : -1
        if piece_to_restore.nil?
          piece_taken, squares[to[0]][to[1] + inc_y] = squares[to[0]][to[1] + inc_y], nil
        else
          squares[from[0]][from[1] + inc_y] = piece_to_restore
        end
        squares[from[0]][from[1]] = nil
      else
        piece_taken, squares[from[0]][from[1]] = squares[to[0]][to[1]], piece_to_restore
      end
      squares[to[0]][to[1]] = piece_to_move
      piece_taken
    end

    def in_check_mate?(player)
      squares_iterator do |x, y|
        next if squares[x][y].nil? || player.color != squares[x][y].color
        poss_moves = find_possible_moves squares[x][y], x, y 
        poss_moves.each do |mov|
          coord_to, coord_from = mov, [x, y]
          taken_piece, temp = make_move(coord_from, coord_to), in_check?(player)
          make_move coord_to, coord_from, taken_piece 
          return false unless temp
        end
      end
      true
    end

    def encastle_left(player) #encastle with the queen's rook
      line = player.color == WHITE ? 7 : 0
      return false if squares[0][line].nil? || squares[0][line].moved || squares[4][line].nil? || squares[4][line].moved ||
                      squares[1][line] || squares[2][line] || squares[3][line] #return false if there's any piece between king and rook
      [[2, line],[3, line],[4, line]].each { |pos| return false if in_check? player, pos }
      make_move [4, line], [2, line]  #move king
      make_move [0, line], [3, line]  #move rook
      true
    end

    def encastle_right(player) #encastle with the king's rook
      line = player.color == WHITE ? 7 : 0
      return false if squares[7][line].nil? || squares[7][line].moved || squares[4][line].nil? || squares[4][line].moved ||
                      squares[5][line] || squares[6][line] #return false if there's any piece between king and rook
      [[4, line],[5, line],[6, line]].each { |pos| return false if in_check?(player, pos) }
      make_move [4, line], [6, line]  #move king
      make_move [7, line], [5, line]  #move rook
      true
    end

    def promote_pawn(at_pos, current_player)
      display_board
      x, y = at_pos
      puts "Choose which piece do you want to promote the pawn to:\nq - Queen\nr - Rook\nn - Knight\nb - Bishop"
      choice = "q" #computer player always promotes to queen
      unless current_player.computer_player
        choice = gets.chomp.downcase
        while (choice.length != 1) || !(choice.match (/q|r|n|b/))
          puts "Invalid choice. Try again."
          choice = gets.chomp.downcase
        end
      end
      color = (y == 7) ? BLACK : WHITE
      squares[x][y] = case choice
        when "q" then Queen.new color 
        when "r" then Rook.new color 
        when "n" then Knight.new color 
        when "b" then Bishop.new color 
      end
      squares[x][y].moved = true
    end

    def opponent_pawn?(pawn, opponent_piece)
      opponent_piece.class == Pawn && opponent_piece.color != pawn.color
    end

    def enable_enpassant(piece, origin, position_x, position_y)
      if piece.class == Pawn && (position_y - origin[1]).abs == 2
        y_inc = piece.color == WHITE ? -1 : 1
        squares[position_x + 1][position_y].enpassant_move = [origin[0], origin[1] + y_inc] if position_x + 1 <= 7 && opponent_pawn?(piece, squares[position_x + 1][position_y])
        squares[position_x - 1][position_y].enpassant_move = [origin[0], origin[1] + y_inc] if position_x - 1 >= 0 && opponent_pawn?(piece, squares[position_x - 1][position_y])
      end
    end

    def clear_enpassant(player)
      squares_iterator {  |x, y| squares[x][y].enpassant_move = Array.new if squares[x][y].class == Pawn && squares[x][y].color == player.color }
    end

    def update_pawn_hypo_moves(piece, coord_to, y_pos)
      if piece.class == Pawn
        squares[coord_to[0]][coord_to[1]].hypo_moves = [[0, -1], [1, -1], [-1, -1]] if (y_pos == 6) && (piece.color == WHITE)
        squares[coord_to[0]][coord_to[1]].hypo_moves = [[0, 1], [1, 1], [-1, 1]] if (y_pos == 1) && (piece.color == BLACK)
      end
    end

    def insufficient_material?
      num_white_bishops, num_white_knights, num_black_bishops, num_black_knights = 0, 0, 0, 0
      squares_iterator do |x, y|
        pc = squares[x][y]
        if pc
          pclass = pc.class
          return false if pclass == Rook || pclass == Pawn || pclass == Queen 
          num_white_bishops += 1 if pclass == Bishop && pc.color == WHITE
          num_white_knights += 1 if pclass == Knight && pc.color == WHITE
          num_black_bishops += 1 if pclass == Bishop && pc.color == BLACK
          num_black_knights += 1 if pclass == Knight && pc.color == BLACK
        end
      end
      return false if num_white_bishops > 1 || num_black_bishops > 1 || num_black_knights > 2 || num_white_knights > 2 ||
                   (num_white_bishops > 0 && num_white_knights > 0) || (num_black_bishops > 0 && num_black_knights > 0)
      true
    end

    def get_piece_code(piece)
      return piece.color[0] + "_N" if piece.class == Chess::Knight
      piece.color[0] + "_" + piece.class.name.split("::").last[0]
    end

    def display_board
      puts "\n    x  0     1     2     3     4     5     6     7 "
      puts " y  #{TABLE_LINES[:l_t_corner]}#{(TABLE_LINES[:h_line]*5 + TABLE_LINES[:mid_top_join])*7}#{TABLE_LINES[:h_line]*5 + TABLE_LINES[:r_t_corner]}"
      (0..7).each do |row|    
        print "    #{TABLE_LINES[:v_line]}"
        (0..7).each do |col|
          bold_italic = @last_selected_piece == [col, row] ?  ["\033[1m\e[3m", "\e[23m\033[0m"] : ["", ""]
          @squares[col][row].nil? ? print("    ") : print("  " + bold_italic.first + UNICODE[get_piece_code(@squares[col][row])] + bold_italic.last + " ")
          print " #{TABLE_LINES[:v_line]}"
        end
        print "\n #{row}  #{TABLE_LINES[:v_line]}"
        (0..7).each do |col|
          bold_italic = @last_selected_piece == [col, row] ?  ["\033[1m\e[3m", "\e[23m\033[0m"] : ["", ""]
          @squares[col][row].nil? ? print("    ") : print(" " + bold_italic.first + get_piece_code(@squares[col][row]) + bold_italic.last)
          print " #{TABLE_LINES[:v_line]}"
        end
        puts "\n    #{TABLE_LINES[:v_l_join]}#{(TABLE_LINES[:h_line]*5 + TABLE_LINES[:mid_join])*7}#{TABLE_LINES[:h_line]*5 + TABLE_LINES[:v_r_join]}" if !(row == 7)
      end
      puts "\n    #{TABLE_LINES[:l_b_corner]}#{(TABLE_LINES[:h_line]*5 + TABLE_LINES[:mid_bot_join])*7}#{TABLE_LINES[:h_line]*5 + TABLE_LINES[:r_b_corner]}"
    end
  end
end
