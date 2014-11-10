require 'yaml'

BLACK = "black"
WHITE = "white"
UNICODE = {"b_R" => "\u265c", "b_N" => "\u265e", "b_B" => "\u265d", "b_Q" => "\u265b", "b_K" => "\u265a", "b_P" => "\u265f", "w_R" => "\u2656", "w_N" => "\u2658", "w_B" => "\u2657", "w_Q" => "\u2655", "w_K" => "\u2654", "w_P" => "\u2659"}
TABLE_LINES = {:v_l_join => "\u251c", :mid_join => "\u253c", :v_r_join => "\u2524", :mid_top_join => "\u252c", :mid_bot_join => "\u2534", :l_t_corner => "\u250c", :r_t_corner => "\u2510", :l_b_corner => "\u2514", :r_b_corner => "\u2518", :v_line => "\u2502", :h_line => "\u2500"}

class Player
  attr_accessor :color, :order_player, :queen_rook_moved, :king_rook_moved, :king_moved, :computer_player
  def initialize(color, order)
    @order_player = order #player1, player2
    @color = color
    @computer_player = false
    #for checking if encastling is possible
    @queen_rook_moved = false
    @king_rook_moved = false
    @king_moved = false
  end
end

class Piece
  attr_accessor :color, :position_x, :position_y, :possible_moves
  def initialize(color)
    @color = color
    @possible_moves = []
  end
end

class Pawn < Piece
  attr_accessor :hypo_moves, :enpassant_move
  def initialize(color)
    super(color)
    @hypo_moves = color == BLACK ? [[0, 1], [0, 2], [1, 1], [-1, 1]] : [[0, -1], [0, -2], [-1, -1], [1, -1]]
    @enpassant_move = []
  end
end

class Rook < Piece
  def initialize(color)
    super(color)
  end
end

class Bishop < Piece
  def initialize(color)
    super(color)
  end
end

class Queen < Piece
  def initialize(color)
    super(color)
  end
end

class King < Piece
  attr_reader :hypo_moves
  def initialize(color)
    super(color)
    @hypo_moves = [[0, -1], [0, 1], [1, -1], [1, 1], [1, 0], [-1, -1], [-1, 1], [-1, 0]]
  end
end

class Knight < Piece
  attr_reader :hypo_moves
  def initialize(color)
    super(color)
    @hypo_moves = [[2, 1], [2, -1], [1, 2], [1, -2], [-2, 1], [-2, -1], [-1, 2], [-1, -2]]
  end
end

class Board
  attr_accessor :squares
  def initialize
    @squares = []
    (0..7).each { @squares.push(Array.new(8, nil))}
  end

  def update_positions
    (0..7).each do |x|
      (0..7).each do |y|
        if !squares[x][y].nil?
          squares[x][y].position_x = x
          squares[x][y].position_y = y
        end
      end
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
    update_positions
  end

  def line_moves(origin_x, origin_y, inc_x, inc_y, start_square, direction)
    moves = []
    i = direction * inc_x
    j = direction * inc_y
    while true
      new_x = origin_x + i
      new_y = origin_y + j
      break if !(new_x.between?(0, 7) && new_y.between?(0, 7))
      square = squares[new_x][new_y]
      if !square.nil?
        moves.push([new_x, new_y]) if square.color != start_square.color
        break
      end
      moves.push([new_x, new_y])
      i += direction * inc_x
      j += direction * inc_y
    end
    return moves
  end

  def get_line_moves(origin_x, origin_y, inc_x, inc_y, start_square)
    return line_moves(origin_x, origin_y, inc_x, inc_y, start_square, 1) + line_moves(origin_x, origin_y, inc_x, inc_y, start_square, -1)
  end

  def find_possible_moves_pawn(piece)
    result = []
    piece.hypo_moves.each do |hm|
      x = piece.position_x + hm[0]
      y = piece.position_y + hm[1]
      next unless (x.between?(0, 7) && y.between?(0, 7))
      if ((squares[x][y] == nil) && (hm[0] == 0))
        result.push([x, y]) if (hm[1].abs == 1)
        result.push([x, y]) if ((squares[x][y - 1] == nil) && (hm[1] == 2) && (piece.color == BLACK))
        result.push([x, y]) if ((squares[x][y + 1] == nil) && (hm[1] == -2) && (piece.color == WHITE))
      end
      result.push([x, y]) if ((squares[x][y] != nil) && (squares[x][y].color != piece.color) && (hm[0] != 0))
    end
    result.push(piece.enpassant_move) unless piece.enpassant_move.empty?
    piece.possible_moves = result
  end

  def find_possible_moves_rook(piece)
    horiz_moves = get_line_moves(piece.position_x, piece.position_y, 1, 0, piece)
    vertical_moves = get_line_moves(piece.position_x, piece.position_y, 0, 1, piece)
    piece.possible_moves = horiz_moves + vertical_moves
  end

  def find_possible_moves_bishop(piece)
    diag1_moves = get_line_moves(piece.position_x, piece.position_y, 1, 1, piece)
    diag2_moves = get_line_moves(piece.position_x, piece.position_y, 1, -1, piece)
    piece.possible_moves = diag1_moves + diag2_moves
  end

  def find_possible_moves_knight(piece)
    result = []
    piece.hypo_moves.each do |hm|
      x = piece.position_x + hm[0]
      y = piece.position_y + hm[1]
      result.push([x, y]) if (x.between?(0, 7) && y.between?(0, 7) && ((squares[x][y] == nil) || (squares[x][y].color != piece.color)))
    end
    piece.possible_moves = result
  end

  def find_possible_moves_queen(piece)
    piece.possible_moves = find_possible_moves_bishop(piece) + find_possible_moves_rook(piece)
  end

  def find_possible_moves_king(piece)
    result = []
    piece.hypo_moves.each do |hm|
      x = piece.position_x + hm[0]
      y = piece.position_y + hm[1]
      result.push([x, y]) if (x.between?(0, 7) && y.between?(0, 7) && ((squares[x][y] == nil) || (squares[x][y].color != piece.color)))
    end
    piece.possible_moves = result
  end

  def find_possible_moves(piece)
    aux = []
    piece_class = piece.class.to_s
    case piece_class
      when "Pawn"
        aux = find_possible_moves_pawn(piece)
      when "Rook"
        aux = find_possible_moves_rook(piece)
      when "Bishop"
        aux = find_possible_moves_bishop(piece)
      when "Knight"
        aux = find_possible_moves_knight(piece)
      when "Queen"
        aux = find_possible_moves_queen(piece)
      when "King"
        aux = find_possible_moves_king(piece)
    end
    aux
  end

  def find_king_coordinates(player) 
    (0..7).each do |x|
      (0..7).each do |y|
        return [x, y] if (!squares[x][y].nil? && (squares[x][y].class == King) && (player.color == squares[x][y].color))
      end
    end
  end

  def in_check?(player, position = nil) #check if player is in check
    position ||= find_king_coordinates(player)
    (0..7).each do |x|
      (0..7).each do |y|
        next if (squares[x][y].nil? || (player.color == squares[x][y].color))
        poss_moves = find_possible_moves(squares[x][y])
        return true if poss_moves.include?(position)
      end
    end
    return false
  end

  def make_move(from, to, piece_to_restore = nil)
    piece_to_move = squares[from[0]][from[1]]
    piece_to_move.position_x = to[0]
    piece_to_move.position_y = to[1]
    piece_taken = nil
    if ((piece_to_move.class == Pawn) && ((piece_to_move.enpassant_move == from) || (piece_to_move.enpassant_move == to)))
      inc_y = (piece_to_move.color == WHITE) ? 1 : -1
      if piece_to_restore.nil?
        piece_taken = squares[to[0]][to[1] + inc_y]
        squares[to[0]][to[1] + inc_y] = nil
      else
        squares[from[0]][from[1] + inc_y] = piece_to_restore
      end
      squares[from[0]][from[1]] = nil
    else
      piece_taken = squares[to[0]][to[1]]
      squares[from[0]][from[1]] = piece_to_restore
    end
    squares[to[0]][to[1]] = piece_to_move
    return piece_taken
  end

  def in_check_mate?(player)
    (0..7).each do |x|
      (0..7).each do |y|
        next if (squares[x][y].nil? || (player.color != squares[x][y].color))
        poss_moves = find_possible_moves(squares[x][y])
        poss_moves.each do |mov|
          coord_to = mov
          coord_from = [x, y]
          taken_piece = make_move(coord_from, coord_to)
          temp = in_check?(player)
          make_move(coord_to, coord_from, taken_piece)
          return false if !temp
        end
      end
    end
    return true
  end

  def encastle_left(player) #encastle with the queen's rook
    player.color == WHITE ? line = 7 : line = 0
    return false if (player.king_moved || player.queen_rook_moved)
    return false if (squares[1][line] || squares[2][line] || squares[3][line]) #return false if there's any piece between king and rook
    [[2, line],[3, line],[4, line]].each do |pos|
      return false if in_check?(player, pos)
    end
    make_move([4, line], [2, line]) #move king
    make_move([0, line], [3, line]) #move rook
    player.king_moved = true
    true
  end

  def encastle_right(player) #encastle with the king's rook
    player.color == WHITE ? line = 7 : line = 0
    return false if (player.king_moved || player.king_rook_moved)
    return false if (squares[5][line] || squares[6][line]) #return false if there's any piece between king and rook
    [[4, line],[5, line],[6, line]].each do |pos|
      return false if in_check?(player, pos)
    end
    make_move([4, line], [6, line]) #move king
    make_move([7, line], [5, line]) #move rook
    player.king_moved = true
    true
  end

  def promote_pawn(at_pos, current_player)
    display_board
    x = at_pos[0]
    y = at_pos[1]
    puts "Choose which piece do you want to promote the pawn to:"
    puts "q - Queen"
    puts "r - Rook"
    puts "n - Knight"
    puts "b - Bishop"
    choice = "q" #computer player always promotes to queen
    if !current_player.computer_player
      choice = gets.chomp.downcase
      while ((choice.length != 1) || !(choice.match /q|r|n|b/))
        puts "Invalid choice. Try again."
        choice = gets.chomp.downcase
      end
    end
    color = (y == 7) ? BLACK : WHITE
    case choice
      when "q"
        squares[x][y] = Queen.new(color)
      when "r"
        squares[x][y] = Rook.new(color)
      when "n"
        squares[x][y] = Knight.new(color)
      when "b"
        squares[x][y] = Bishop.new(color)
    end
    squares[x][y].position_x = x
    squares[x][y].position_y = y
  end

  def opponent_pawn?(pawn, opponent_piece)
    return true if (opponent_piece.class == Pawn) && (opponent_piece.color != pawn.color)
    false
  end

  def enable_enpassant(piece, origin)
    if ((piece.class == Pawn) && ((piece.position_y - origin[1]).abs == 2))
      y_inc = piece.color == WHITE ? -1 : 1
      if ((piece.position_x + 1 <= 7) && (opponent_pawn?(piece, squares[piece.position_x + 1][piece.position_y])))
        squares[piece.position_x + 1][piece.position_y].enpassant_move = [origin[0], origin[1] + y_inc]
      end
      if ((piece.position_x - 1 >= 0) && (opponent_pawn?(piece, squares[piece.position_x - 1][piece.position_y])))
        squares[piece.position_x - 1][piece.position_y].enpassant_move = [origin[0], origin[1] + y_inc]
      end
    end
  end

  def clear_enpassant(player)
    (0..7).each do |x|
      (0..7).each do |y|
        squares[x][y].enpassant_move = [] if (squares[x][y].class == Pawn) && (squares[x][y].color == player.color)
      end
    end
  end

  def update_pawn_hypo_moves(piece, coord_to, y_pos)
    if piece.class == Pawn
      squares[coord_to[0]][coord_to[1]].hypo_moves = [[0, -1], [1, -1], [-1, -1]] if (y_pos == 6) && (piece.color == WHITE)
      squares[coord_to[0]][coord_to[1]].hypo_moves = [[0, 1], [1, 1], [-1, 1]] if (y_pos == 1) && (piece.color == BLACK)
    end
  end

  def get_piece_code(piece)
    return piece.color[0] + "_N" if piece.class == Knight
    return piece.color[0] + "_" + piece.class.to_s[0]
  end

  def display_board
    puts "\n    x  0     1     2     3     4     5     6     7 "
    puts " y  #{TABLE_LINES[:l_t_corner]}#{(TABLE_LINES[:h_line]*5 + TABLE_LINES[:mid_top_join])*7}#{TABLE_LINES[:h_line]*5 + TABLE_LINES[:r_t_corner]}"
    (0..7).each do |row|    
      print "    #{TABLE_LINES[:v_line]}"
      (0..7).each do |col|
          @squares[col][row].nil? ? print("    "): print("  " + UNICODE[get_piece_code(@squares[col][row])] + " ")
          print " #{TABLE_LINES[:v_line]}"
      end
      puts
      print " #{row}  #{TABLE_LINES[:v_line]}"
      (0..7).each do |col|
          @squares[col][row].nil? ? print("    "): print(" " + get_piece_code(@squares[col][row]))
          print " #{TABLE_LINES[:v_line]}"
      end
      puts "\n    #{TABLE_LINES[:v_l_join]}#{(TABLE_LINES[:h_line]*5 + TABLE_LINES[:mid_join])*7}#{TABLE_LINES[:h_line]*5 + TABLE_LINES[:v_r_join]}" if !(row == 7)
    end
    puts "\n    #{TABLE_LINES[:l_b_corner]}#{(TABLE_LINES[:h_line]*5 + TABLE_LINES[:mid_bot_join])*7}#{TABLE_LINES[:h_line]*5 + TABLE_LINES[:r_b_corner]}"
  end
end

class Game
  attr_accessor :board, :player1, :player2, :game_file, :next_to_play
  def initialize(board = nil)
    @board = board || Board.new
    @game_file = nil
    @next_to_play = nil
  end

  def save_game
    Dir.mkdir("saved_games") if !Dir.exists?("saved_games")
    if @game_file.nil?
      list_files = Dir["saved_games/*"]
      list_ids = list_files.collect { |fname| fname.scan(/\d+/).join.to_i }
      new_id = list_ids.empty? ? 1 : list_ids.max + 1
      @game_file = "saved_games/game#{new_id}.txt"
    end
    File.open(@game_file, "w").write(YAML::dump([self]))
    puts "file saved as " + game_file
  end

  def load_game 
    list_files = Dir["saved_games/*"]
    list_ids = list_files.collect { |fname| fname.scan(/\d+/).join.to_i }
    if list_ids.empty?
      puts "There are no saved games to be loaded"
      return false
    end
    puts "Choose the id of the file to load: "
    puts list_ids.inspect
    id_load = gets.chomp
    if File.exists?("saved_games/game#{id_load}.txt")
      data = File.open("saved_games/game#{id_load}.txt", "r").readlines.join
      values = YAML::load(data)
      self.board = values[0].board
      self.player1 = values[0].player1
      self.player2 = values[0].player2
      self.game_file = values[0].game_file
      self.next_to_play = values[0].next_to_play
      return true
    end
    puts "File game#{id_load}.txt does not exist"
    false
  end

  def print_message(msg)
    block = "\u2593"
    puts "#{block*6}#{block*msg.length}#{block*7}"
    puts "#{block*2}#{' '*(msg.length + 9)}#{block*2}"
    puts "#{block*2}     #{msg}    #{block*2}"
    puts "#{block*2}#{' '*(msg.length + 9)}#{block*2}"
    puts "#{block*6}#{block*msg.length}#{block*7}"
  end

  def print_board_and_message(msg)
    board.display_board
    print_message(msg)
  end

  #verify if the player's king or rooks moved or if any of the opponents rooks was taken in order to invalidate the corresponding encastling move
  def check_rooks_king_moved(piece, player, opponent, coord_from, coord_to)
    if piece.class == King
      player.king_moved = true
    else
      player_first_rank = (player.color == BLACK) ? 0 : 7
      opponent_first_rank = (player_first_rank - 7).abs
      player.queen_rook_moved = true if coord_from == [0, player_first_rank]
      player.king_rook_moved = true if coord_from == [7, player_first_rank]
      # case when player takes one of the opponent's rooks at their initial positions
      opponent.queen_rook_moved = true if coord_to == [0, opponent_first_rank]
      opponent.king_rook_moved = true if coord_to == [7, opponent_first_rank]
    end
  end

  def get_moves_and_score(mock_board, player, opponent)
    list_moves = []
    (0..7).each do |x|
      (0..7).each do |y|
        if ((mock_board.squares[x][y] != nil) && (mock_board.squares[x][y].color == player.color))
          p_moves = mock_board.find_possible_moves(mock_board.squares[x][y])
          p_moves.each do |m|
            p_taken = mock_board.make_move([x, y], m)
            score = 0
            if p_taken != nil
              p_taken_class = p_taken.class.to_s
              case p_taken_class
              when "Pawn"
                score = 1   
              when "Rook"
                score = 4  
              when "Bishop"
                score = 3  
              when "Knight"
                score = 3  
              when "Queen"
                score = 5
              end
              score += 1 if mock_board.in_check?(opponent)
            end
            list_moves.push([score,[x, y], m]) if !(mock_board.in_check?(player))
            mock_board.make_move(m, [x, y], p_taken)
          end
        end
      end
    end
    list_moves
  end

  def get_max_score(list)
    max = 0
    list.each { |elem| max = elem[0] if (elem[0] > max) }
    max
  end

  def get_computer_move(board, player, opponent)
    mock_board = board.dup #clone?
    list_moves = get_moves_and_score(mock_board, player, opponent)
    aux_list = []
    m_board = mock_board.dup
    opp = opponent.dup
    plr = player.dup  
    list_moves.each do |m|
      p_taken = m_board.make_move(m[1], m[2])
      subtract_score = get_max_score(get_moves_and_score(m_board, opp, plr))
      m_board.make_move(m[2], m[1], p_taken)
      aux_elem = m
      aux_elem[0] -= subtract_score
      aux_list.push(aux_elem)
    end
    aux_list.shuffle!
    pc_move = [aux_list.first[1], aux_list.first[2]]
    pc_move_score = aux_list.first[0]
    aux_list.each do |mv|
      if mv[0] > pc_move_score
        pc_move = [mv[1], mv[2]]
        pc_move_score = mv[0]
      end
    end
    return [pc_move[0][0].to_s + pc_move[0][1].to_s, pc_move[1][0].to_s + pc_move[1][1].to_s]
  end

  def count_remaining_pieces
    count = 0
    (0..7).each do |x|
      (0..7).each do |y|
        count += 1 if board.squares[x][y]
      end
    end
    count
  end

  def get_xy
    while true
      xy = gets.chomp
      if ((xy.length == 2) && (xy.match /[0-7][0-7]|88|99/))
        return xy
      elsif ((xy.length == 1) && (xy.match /s|S|q|Q/))
        return xy
      else
        board.display_board
        puts "\n\nInvalid input. Try again.\n\n\n"
      end
    end
  end

  def player_turn(player)
    if count_remaining_pieces < 3
      print_message("The game ended in a tie.")
      return true
    end
    opponent = (@player1 == player) ? @player2 : @player1
    while true
      puts "\n#{player.order_player}, #{player.color}\'s turn"
      board.display_board
      puts "\nWrite 's' to save the game."
      puts "Write 'q' to exit the game without saving."
      puts "Choose the coordinates of the piece to move (xy),"
      puts "or write '88' to encastle with the queen's rook or '99' to encastle with the king's rook."
      sleep(1) if player.computer_player && opponent.computer_player
      comp_move = []
      if player.computer_player
        comp_move = get_computer_move(board, player.dup, opponent.dup)
        xy_origin = comp_move[0]
      else
        xy_origin = get_xy
      end
      return true if xy_origin.downcase == "q"
      if xy_origin.downcase == "s"
        save_game
        next
      end
      if xy_origin == "88"
        break if board.encastle_left(player)
        print_board_and_message("It is not possible to encastle with the queen's rook.")
        next
      elsif xy_origin == "99"
        break if board.encastle_right(player)
        print_board_and_message("It is not possible to encastle with the king's rook.")
        next
      end
      coord_from = xy_origin.split('')
      coord_from = [coord_from[0].to_i, coord_from[1].to_i]
      if (board.squares[coord_from[0]][coord_from[1]].nil?)
        print_board_and_message("There's no piece to move at those coordinates. Try again.")
        next
      elsif (board.squares[coord_from[0]][coord_from[1]].color != player.color)
        print_board_and_message("You can't move your opponent's pieces. Try again.")
        next
      end 
      piece = board.squares[coord_from[0]][coord_from[1]]
      board.find_possible_moves(piece)
      board.display_board
      puts "\n\nChoose the coordinates of the place to move the piece to (xy)\n\n\n"
      if player.computer_player
        xy_dest = comp_move[1]
      else
        xy_dest = get_xy
      end
      coord_to = xy_dest.split('')
      coord_to = [coord_to[0].to_i, coord_to[1].to_i]
      if piece.possible_moves.include? ([coord_to[0], coord_to[1]])    
        piece_at_dest = board.make_move(coord_from, coord_to)
        
        if board.in_check?(player)
          print_board_and_message("You can't make that move. You'll be in check.")
          board.make_move(coord_to, coord_from, piece_at_dest)
          next
        end
        board.clear_enpassant(player) #revoke the possibility of making en passant moves
        board.enable_enpassant(piece, coord_from) #if piece is a pawn and moves two squares check if opponent has won the right to an enpassant move
        board.promote_pawn(coord_to, player) if ((piece.class == Pawn) && ((coord_to[1] == 0) || (coord_to[1] == 7)))
        board.update_pawn_hypo_moves(piece, coord_to, coord_from[1])
        if board.in_check?(opponent)
          if board.in_check_mate?(opponent)
            print_board_and_message("Checkmate! " + player.color + " player has won the game.")
            return true
          end
          print_message(opponent.color + " king is in check!")
        else #check for stalemate
          if board.in_check_mate?(opponent) #check if any possible move results in check while not being in check in the current position
            print_board_and_message("The game ended in a stalemate.")
            return true
          end
        end
        check_rooks_king_moved(piece, player, opponent, coord_from, coord_to)
        break
      else
        print_board_and_message("That move is not allowed. Choose again.")
      end
    end
    nil
  end

  def select_game_mode
    puts "Choose game mode:"
    puts "a - Both players are humans"
    puts "b - Player1 (white) is human and player2 (black) is the computer"
    puts "c - Player2 (black) is human and player1 (white) is the computer"
    puts "d - Play the computer against the computer (Warning: this may result in an infinite loop. Use Ctrl+C to terminate the program.)"
    choice = gets.chomp.downcase
    while ((choice.length != 1) || !(choice.match /a|b|c|d/))
      puts "Invalid choice. Try again."
      choice = gets.chomp.downcase
    end
    case choice
      when "a"
        @player1.computer_player = false
        @player2.computer_player = false
      when "b"
        @player1.computer_player = false
        @player2.computer_player = true
      when "c"
        @player1.computer_player = true
        @player2.computer_player = false
      when "d"
        @player1.computer_player = true
        @player2.computer_player = true
    end
  end

  def menu
    @player1 = Player.new(WHITE, "player1")
    @player2 = Player.new(BLACK, "player2")
    @board.create_pieces
    if Dir.exists?("saved_games")
      puts "Do you want to load a saved game? (y/n)"
      load_saved = gets[0].downcase
      if (load_saved == "y") && load_game
        if @next_to_play == BLACK
          return if player_turn(@player2)
          @next_to_play = @player1.color
        end
      else
        select_game_mode
      end
    else
      select_game_mode
    end
    loop do
      break if player_turn(@player1)
      @next_to_play = @player2.color
      break if player_turn(@player2)
      @next_to_play = @player1.color
    end
  end
end

g = Game.new
g.menu
