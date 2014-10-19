require 'yaml'

class Player
  attr_accessor :color, :order_player, :queen_rook_moved, :king_rook_moved, :king_moved
  def initialize(color, order)
    @order_player = order #player1, player2
    @color = color
    #useful when checking if encastling is possible
    @queen_rook_moved = false
    @king_rook_moved = false
    @king_moved = false
  end
end

class Piece
  attr_accessor :color, :position_x, :position_y
  def initialize(color, position_x, position_y)
    @color = color
    @position_x = position_x
    @position_y = position_y
  end
end

class BlackPawn < Piece
  attr_accessor :hypo_moves, :possible_moves
  def initialize(color, x, y)
    super(color, x, y)
    @hypo_moves = [[0, 1], [0, 2], [1, 1], [-1, 1]]
    @possible_moves = @hypo_moves
  end
end

class WhitePawn < Piece
  attr_accessor :hypo_moves, :possible_moves
  def initialize(color, x, y)
    super(color, x, y)
    @hypo_moves = [[0, -1], [0, -2], [-1, -1], [1, -1]]
    @possible_moves = @hypo_moves
  end
end

class Rook < Piece
  attr_accessor :possible_moves
  def initialize(color, x, y)
    super(color, x, y)
    @possible_moves = []
  end
end

class Bishop < Piece
  attr_accessor :possible_moves
  def initialize(color, x, y)
    super(color, x, y)
    @possible_moves = []
  end
end

class Queen < Piece
  attr_accessor :possible_moves
  def initialize(color, x, y)
    super(color, x, y)
    @possible_moves = []
  end
end

class King < Piece
  attr_accessor :hypo_moves, :possible_moves
  def initialize(color, x, y)
    super(color, x, y)
    @hypo_moves = [[0, -1], [0, 1], [1, -1], [1, 1], [1, 0], [-1, -1], [-1, 1], [-1, 0]]
    @possible_moves = []
  end
end

class Knight < Piece
  attr_accessor :hypo_moves, :possible_moves
  def initialize(color, x, y)
    super(color, x, y)
    @hypo_moves = [[2, 1], [2, -1], [1, 2], [1, -2], [-2, 1], [-2, -1], [-1, 2], [-1, -2]]
    @possible_moves = []
  end
end

class Board
  attr_reader :squares
  def initialize
    @unicode = {"b_R" => "\u265c", "b_N" => "\u265e", "b_B" => "\u265d", "b_Q" => "\u265b", "b_K" => "\u265a", "b_P" => "\u265f", "w_R" => "\u2656", "w_N" => "\u2658", "w_B" => "\u2657", "w_Q" => "\u2655", "w_K" => "\u2654", "w_P" => "\u2659", }
    @squares = []
    (0..7).each { @squares.push(Array.new(8, nil))}
  end

  def create_pieces
    (0..7).each do |pos|
      @squares[pos][1] = BlackPawn.new("black", pos, 1)
    end
    (0..7).each do |pos|
      @squares[pos][6] = WhitePawn.new("white", pos, 6)
    end

    @squares[0][0] = Rook.new("black", 0, 0)
    @squares[7][0] = Rook.new("black", 7, 0)
    @squares[0][7] = Rook.new("white", 0, 7)
    @squares[7][7] = Rook.new("white", 7, 7)

    @squares[1][0] = Knight.new("black", 1, 0)
    @squares[6][0] = Knight.new("black", 6, 0)
    @squares[1][7] = Knight.new("white", 1, 7)
    @squares[6][7] = Knight.new("white", 6, 7)

    @squares[2][0] = Bishop.new("black", 2, 0)
    @squares[5][0] = Bishop.new("black", 5, 0)
    @squares[2][7] = Bishop.new("white", 2, 7)
    @squares[5][7] = Bishop.new("white", 5, 7)

    @squares[3][0] = Queen.new("black", 3, 0)
    @squares[3][7] = Queen.new("white", 3, 7)
    @squares[4][0] = King.new("black", 4, 0)
    @squares[4][7] = King.new("white", 4, 7)
  end

  def get_line_moves(origin_x, origin_y, inc_x, inc_y, start_square)
    moves = []
    i = inc_x
    j = inc_y
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
      i += inc_x
      j += inc_y
    end
    i = -inc_x
    j = -inc_y
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
      i -= inc_x
      j -= inc_y
    end
    return moves
  end

  def get_list_of_moves_for_pawns(piece)
    result = []
    piece.hypo_moves.each do |hm|
      x = piece.position_x + hm[0]
      y = piece.position_y + hm[1]
      next unless (x.between?(0, 7) && y.between?(0, 7))
      if ((squares[x][y] == nil) && (hm[0] == 0) && (hm[1].abs == 1))
        result.push([x, y])
      end
      if (squares[x][y] == nil) && (hm[0] == 0) && ((squares[x][y - 1] == nil) && (hm[1] == 2)) || ((squares[x][y + 1] == nil) && (hm[1] == -2))
        result.push([x, y])
      end
      result.push([x, y]) if ((squares[x][y] != nil) && (squares[x][y].color != piece.color) && (hm[0] != 0))
    end
    result
  end

  def find_possible_moves_black_pawn(piece)
    piece.hypo_moves = [[0, 1], [1, 1], [-1, 1]] if piece.position_y != 1
    piece.possible_moves = get_list_of_moves_for_pawns(piece)
  end

  def find_possible_moves_white_pawn(piece)
    piece.hypo_moves = [[0, -1], [1, -1], [-1, -1]] if piece.position_y != 6
    piece.possible_moves = get_list_of_moves_for_pawns(piece)
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
    horiz_moves = get_line_moves(piece.position_x, piece.position_y, 1, 0, piece)
    vertical_moves = get_line_moves(piece.position_x, piece.position_y, 0, 1, piece)
    diag1_moves = get_line_moves(piece.position_x, piece.position_y, 1, 1, piece)
    diag2_moves = get_line_moves(piece.position_x, piece.position_y, 1, -1, piece)
    piece.possible_moves = horiz_moves + vertical_moves + diag1_moves + diag2_moves
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
      when "BlackPawn"
        aux = find_possible_moves_black_pawn(piece)
      when "WhitePawn"
        aux = find_possible_moves_white_pawn(piece)
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

  def find_opponent_king_coordinates(player) 
    (0..7).each do |x|
      (0..7).each do |y|
        return [x, y] if (!squares[x][y].nil? && (squares[x][y].class == King) && (player.color != squares[x][y].color))
      end
    end
  end

  def check_by?(player) #check whether the opponent of player is in check
    king_coord_opponent = find_opponent_king_coordinates(player)
    (0..7).each do |x|
      (0..7).each do |y|
        if (squares[x][y].nil? || (player.color != squares[x][y].color))
          next
        end
        poss_moves = find_possible_moves(squares[x][y])
        return true if poss_moves.include?(king_coord_opponent)
      end
    end
    return false
  end

  def make_move(from, to, piece_to_restore = nil)
    piece_to_move = squares[from[0].to_i][from[1].to_i]
    piece_to_move.position_x = to[0].to_i
    piece_to_move.position_y = to[1].to_i
    squares[to[0].to_i][to[1].to_i] = piece_to_move
    squares[from[0].to_i][from[1].to_i] = piece_to_restore
  end

  def check_mate_by?(player)
    #for each of the opponent pieces
      #make all possible moves
        #if there's any that removes the check condition then return false
    (0..7).each do |x|
      (0..7).each do |y|
        if (squares[x][y].nil? || (player.color == squares[x][y].color))
          next
        end
        poss_moves = find_possible_moves(squares[x][y])
        poss_moves.each do |mov|
          coord_to = mov
          coord_from = [x, y]
          piece_at_dest = squares[coord_to[0].to_i][coord_to[1].to_i]
          make_move(coord_from, coord_to)
          temp = check_by?(player)
          make_move(coord_to, coord_from, piece_at_dest)
          return false if !temp
        end
      end
    end
    return true
  end

  def checked_encastle?(player, position)
    (0..7).each do |x|
      (0..7).each do |y|
        if (squares[x][y].nil? || (player.color == squares[x][y].color))
          next
        end
        poss_moves = find_possible_moves(squares[x][y])
        return true if poss_moves.include?(position)
      end
    end
    return false
  end

  def encastle_left(player) #encastle with the queen's rook
    player.color == "white" ? line = 7 : line = 0
    return false if (player.king_moved || player.queen_rook_moved)
    return false if !(squares[1][line].nil? && squares[2][line].nil? && squares[3][line].nil?)
    [[2, line],[3, line],[4, line]].each do |pos|
      return false if checked_encastle?(player, pos)
    end
    make_move([4, line], [2, line]) #move king
    make_move([0, line], [3, line]) #move rook
    player.king_moved = true
    true
  end

  def encastle_right(player) #encastle with the king's rook
    player.color == "white" ? line = 7 : line = 0
    return false if (player.king_moved || player.king_rook_moved)
    return false if !(squares[5][line].nil? && squares[6][line].nil?)
    [[4, line],[5, line],[6, line]].each do |pos|
      return false if checked_encastle?(player, pos)
    end
    make_move([4, line], [6, line]) #move king
    make_move([7, line], [5, line]) #move rook
    player.king_moved = true
    true
  end

  def promote_pawn(at_pos)
    display_board
    x = at_pos[0].to_i
    y = at_pos[1].to_i
    puts "Choose which piece do you want to promote the pawn to:"
    puts "q - Queen"
    puts "r - Rook"
    puts "n - Knight"
    puts "b - Bishop"
    choice = gets.chomp.downcase
    while ((choice.length != 1) || !(choice.match /q|r|n|b/))
      puts "Invalid choice. Try again."
      choice = gets.chomp.downcase
    end
    y == 7 ? color = "black" : color = "white"
    case choice
      when "q"
        squares[x][y] = Queen.new(color, x, y)
      when "r"
        squares[x][y] = Rook.new(color, x, y)
      when "k"
        squares[x][y] = Knight.new(color, x, y)
      when "b"
        squares[x][y] = Bishop.new(color, x, y)
    end
  end

  def get_piece_code(piece)
    return piece.color[0] + "_P" if ((piece.class == WhitePawn) || (piece.class == BlackPawn))
    return piece.color[0] + "_N" if piece.class == Knight
    return piece.color[0] + "_" + piece.class.to_s[0]
  end

  def display_board
    puts "\n    x  0     1     2     3     4     5     6     7 "
    puts " y  -------------------------------------------------"
    (0..7).each do |row|  
      
      print "    |"
      (0..7).each do |col|
          @squares[col][row].nil? ? print("    "): print("  " + @unicode[get_piece_code(@squares[col][row])] + " ")
          print " |"
      end
      puts #"\n"
      print " #{row}  |"
      (0..7).each do |col|
          @squares[col][row].nil? ? print("    "): print(" " + get_piece_code(@squares[col][row]))
          print " |"
      end
      puts "\n    |-----|-----|-----|-----|-----|-----|-----|-----|" unless row == 7
    end
    puts "\n    -------------------------------------------------"
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
      list_ids = list_files.collect { |fname| fname.scan(/\d/).join.to_i }
      new_id = list_ids.empty? ? 1 : list_ids.max + 1
      @game_file = "saved_games/game#{new_id}.txt"
    end
    File.open(@game_file, "w").write(YAML::dump([self]))
    puts "file saved as " + game_file
  end

  def load_game
    
    if !Dir.exists?("saved_games")
      puts "There are no saved games to be loaded"
      return false
    end
    list_files = Dir["saved_games/*"]
    list_ids = list_files.collect { |fname| fname.scan(/\d/).join.to_i }
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

  def print_important_message(msg)
    puts
    puts "%%%%%%%#{'%'*msg.length}%%%%%%%"
    puts "%%     #{msg}     %%"
    puts "%%%%%%%#{'%'*msg.length}%%%%%%%"
    puts
  end

  def get_xy
    while true
      xy = gets.chomp
      if ((xy.length == 2) && (xy.match /[0-7][0-7]|88|99/))
        return xy
      elsif ((xy.length == 1) && (xy.match /s|S|q|Q/))
        return xy
      else
        puts "Invalid input. Try again."
      end
    end
  end

  def player_turn(player)
    
    puts "\n#{player.order_player}, #{player.color}\'s turn"
    while true
      puts "Write 's' to save the game."
      puts "Write 'q' to exit the game without saving."
      puts "Choose the coordinates of the piece to move (xy),"
      puts "or write '88' to encastle with the queen's rook or '99' to encastle with the king's rook."
      xy_origin = get_xy
      return true if xy_origin.downcase == "q"
      if xy_origin.downcase == "s"
        save_game
        next
      end
      if xy_origin == "88"
        break if board.encastle_left(player)
        puts "It is not possible to encastle with the queen's rook."
        next
      elsif xy_origin == "99"
        break if board.encastle_right(player)
        puts "It is not possible to encastle with the king's rook."
        next
      end
      coord_from = xy_origin.split('')
      if (board.squares[coord_from[0].to_i][coord_from[1].to_i].nil?)
        puts "There's no piece to move at those coordinates. Try again."
        next
      elsif (board.squares[coord_from[0].to_i][coord_from[1].to_i].color != player.color)
        puts "You can't move your opponent's pieces. Try again."
        next
      end 
      piece = board.squares[coord_from[0].to_i][coord_from[1].to_i]
      board.find_possible_moves(piece)
      puts "Choose the coordinates of the place to move the piece to (xy)"
      xy_dest = get_xy
      coord_to = xy_dest.split('')
      if piece.possible_moves.include? ([coord_to[0].to_i, coord_to[1].to_i])    
        piece_at_dest = board.squares[coord_to[0].to_i][coord_to[1].to_i]
        board.make_move(coord_from, coord_to)
        
        opponent = (@player1 == player) ? @player2 : @player1
        if board.check_by?(opponent)
          print_important_message("You can't make that move. You'll be in check.")
          board.make_move(coord_to, coord_from, piece_at_dest)
          next
        end
        board.promote_pawn(coord_to) if (((piece.class == WhitePawn) || (piece.class == BlackPawn)) && ((coord_to[1] == "0") || (coord_to[1] == "7")))
        if board.check_by?(player)
          if board.check_mate_by?(player)
            board.display_board
            print_important_message(player.color + " has won the game.")
            return true
          end
          print_important_message(player.color + " has checked his opponent!")
        else
          #check for stalemate
          if board.check_mate_by?(player) #check if any possible move results in check while not being in check in the current position
            board.display_board
            print_important_message("The game ended in a stalemate.")
            return true
          end
        end
        if piece.class == King
          player.king_moved = true
        elsif piece.class == Rook
          player.queen_rook_moved = true if piece.position_x == 0
          player.king_rook_moved = true if piece.position_x == 7
        end
        break
      else
        puts "That move is not allowed. Choose again."
      end
    end
    nil
  end

  def menu
    puts "Do you want to load a saved game? (y/n)"
    load_saved = gets[0].downcase
    if (load_saved == "y") && load_game
      if @next_to_play == "black"
        board.display_board
        return if player_turn(@player2)
        @next_to_play = @player1.color
      end
    else
      @player1 = Player.new("white", "player1")
      @player2 = Player.new("black", "player2")
      @board.create_pieces
    end
    loop do
      board.display_board
      break if player_turn(@player1)
      @next_to_play = @player2.color
      board.display_board
      break if player_turn(@player2)
      @next_to_play = @player1.color
    end
  end

end


g = Game.new
g.menu

