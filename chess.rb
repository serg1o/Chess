class Player
  attr_accessor :color, :order_player, :queen_rook_moved, :king_rook_moved, :king_moved
  def initialize(color, order)
    @order_player = order #player1, player2 etc
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
    @hypo_moves = [[0, 1], [0, 2], [1, 1], [-1, 1]] #black pawn hypothetical moves are 1 or 2 squares forward and 0 sideways from current position
    @possible_moves = @hypo_moves
  end
end

class WhitePawn < Piece
  attr_accessor :hypo_moves, :possible_moves
  def initialize(color, x, y)
    super(color, x, y)
    @hypo_moves = [[0, -1], [0, -2], [-1, -1], [1, -1]] #white pawn hypothetical moves are 1 or 2 squares forward and 0 sideways from current position
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
  attr_reader :board
  def initialize
    @unicode = {"bRk" => "\u265c", "bKt" => "\u265e", "bBp" => "\u265d", "bQn" => "\u265b", "bKg" => "\u265a", "bPn" => "\u265f", "wRk" => "\u2656", "wKt" => "\u2658", "wBp" => "\u2657", "wQn" => "\u2655", "wKg" => "\u2654", "wPn" => "\u2659", }
    @board = []
    (0..7).each { @board.push(Array.new(8, nil))}

    (0..7).each do |pos|
      @board[pos][1] = BlackPawn.new("black", pos, 1)
    end
    (0..7).each do |pos|
      @board[pos][6] = WhitePawn.new("white", pos, 6)
    end
    @board[0][0] = Rook.new("black", 0, 0)
    @board[7][0] = Rook.new("black", 7, 0)
    @board[0][7] = Rook.new("white", 0, 7)
    @board[7][7] = Rook.new("white", 7, 7)

    @board[1][0] = Knight.new("black", 1, 0)
    @board[6][0] = Knight.new("black", 6, 0)
    @board[1][7] = Knight.new("white", 1, 7)
    @board[6][7] = Knight.new("white", 6, 7)

    @board[2][0] = Bishop.new("black", 2, 0)
    @board[5][0] = Bishop.new("black", 5, 0)
    @board[2][7] = Bishop.new("white", 2, 7)
    @board[5][7] = Bishop.new("white", 5, 7)

    @board[3][0] = Queen.new("black", 3, 0)
    @board[3][7] = Queen.new("white", 3, 7)
    @board[4][0] = King.new("black", 4, 0)
    @board[4][7] = King.new("white", 4, 7)

  end

  def get_line_moves(origin_x, origin_y, inc_x, inc_y, start_square)
    moves = []
    i = inc_x
    j = inc_y
    while true
      new_x = origin_x + i
      new_y = origin_y + j
      break if !(new_x.between?(0, 7) && new_y.between?(0, 7))
      square = board[new_x][new_y]
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
      square = board[new_x][new_y]
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
      result.push([x, y]) if (x.between?(0, 7) && y.between?(0, 7) && (board[x][y] == nil) && (hm[0] == 0))
      result.push([x, y]) if (x.between?(0, 7) && y.between?(0, 7) && (board[x][y] != nil) && (board[x][y].color != piece.color) && (hm[0] != 0))
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
      result.push([x, y]) if (x.between?(0, 7) && y.between?(0, 7) && ((board[x][y] == nil) || (board[x][y].color != piece.color)))
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
      result.push([x, y]) if (x.between?(0, 7) && y.between?(0, 7) && ((board[x][y] == nil) || (board[x][y].color != piece.color)))
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
        return [x, y] if (!board[x][y].nil? && (board[x][y].class == King) && (player.color != board[x][y].color))
      end
    end
  end

  def checked?(player) #check whether the opponent of player is in check
    king_coord_opponent = find_opponent_king_coordinates(player)
    (0..7).each do |x|
      (0..7).each do |y|
        if (board[x][y].nil? || (player.color != board[x][y].color))
          next
        end
        poss_moves = find_possible_moves(board[x][y])
        return true if poss_moves.include?(king_coord_opponent)
      end
    end
    return false
  end

  def make_move(from, to, piece_to_restore = nil)
    piece_to_move = board[from[0].to_i][from[1].to_i]
    piece_to_move.position_x = to[0].to_i
    piece_to_move.position_y = to[1].to_i
    board[to[0].to_i][to[1].to_i] = piece_to_move
    board[from[0].to_i][from[1].to_i] = piece_to_restore
  end

  def check_mate?(player)
    #for each of the opponent pieces
      #make all possible moves
        #if there's any that removes the checked condition then return false
    (0..7).each do |x|
      (0..7).each do |y|
        if (board[x][y].nil? || (player.color == board[x][y].color))
          next
        end
        poss_moves = find_possible_moves(board[x][y])
        poss_moves.each do |mov|
          coord_to = mov
          coord_from = [x, y]
          piece_at_dest = board[coord_to[0].to_i][coord_to[1].to_i]
          make_move(coord_from, coord_to)
          temp = checked?(player)
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
        if (board[x][y].nil? || (player.color == board[x][y].color))
          next
        end
        poss_moves = find_possible_moves(board[x][y])
        return true if poss_moves.include?(position)
      end
    end
    return false
  end

  def encastle_left(player)
    if player.color == "white"
      return false if (player.king_moved || player.queen_rook_moved)
      return false if !(board[1][7].nil? && board[2][7].nil? && board[3][7].nil?)
      [[2, 7],[3, 7],[4, 7]].each do |pos|
        return false if checked_encastle?(player, pos)
      end
      make_move([4, 7], [2, 7]) #move king
      make_move([0, 7], [3, 7]) #move rook
    elsif player.color == "black"
      return false if (player.king_moved || player.king_rook_moved)
      return false if !(board[5][0].nil? && board[6][0].nil?)
      [[4, 0],[5, 0],[6, 0]].each do |pos|
        return false if checked_encastle?(player, pos)
      end
      make_move([4, 0], [6, 0])
      make_move([7, 0], [5, 0])
    end
    player.king_moved = true
    true
  end

  def encastle_right(player) 
    if player.color == "white"
      return false if (player.king_moved || player.king_rook_moved)
      return false if !(board[5][7].nil? && board[6][7].nil?)
      [[4, 7],[5, 7],[6, 7]].each do |pos|
        return false if checked_encastle?(player, pos)
      end
      make_move([4, 7], [6, 7]) #move king
      make_move([7, 7], [5, 7]) #move rook
    elsif player.color == "black"
      return false if (player.king_moved || player.queen_rook_moved)
      return false if !(board[1][0].nil? && board[2][0].nil? && board[3][0].nil?)
      [[2, 0],[3, 0],[4, 0]].each do |pos|
        return false if checked_encastle?(player, pos)
      end
      make_move([4, 0], [2, 0])
      make_move([0, 0], [3, 0])
    end
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
    puts "k - Knight"
    puts "b - Bishop"
    choice = gets.chomp.downcase
    while ((choice.length != 1) || !(choice.match /q|r|k|b/))
      puts "Invalid choice. Try again."
      choice = gets.chomp.downcase
    end
    y == 7 ? color = "black" : color = "white"
    case choice
      when "q"
        board[x][y] = Queen.new(color, x, y)
      when "r"
        board[x][y] = Rook.new(color, x, y)
      when "k"
        board[x][y] = Knight.new(color, x, y)
      when "b"
        board[x][y] = Bishop.new(color, x, y)
    end
  end

  def get_piece_code(piece)
    return piece.color[0] + "Pn" if ((piece.class == WhitePawn) || (piece.class == BlackPawn))
    return piece.color[0] + piece.class.to_s[0] + piece.class.to_s[-1]
  end

  def display_board
    puts "\n    x  0     1     2     3     4     5     6     7 "
    puts " y  -------------------------------------------------"
    (0..7).each do |c_index|  
      
      print "    |"
      (0..7).each do |row|
          @board[row][c_index].nil? ? print("    "): print("  " + @unicode[get_piece_code(@board[row][c_index])] + " ")
          print " |"
      end
      puts #"\n"
      print " #{c_index}  |"
      (0..7).each do |row|
          @board[row][c_index].nil? ? print("    "): print(" " + get_piece_code(@board[row][c_index]))
          print " |"
      end
      puts "\n    |-----|-----|-----|-----|-----|-----|-----|-----|" unless c_index == 7
    end
    puts "\n    -------------------------------------------------"
  end

end

class Game
  attr_accessor :game_board
  def initialize(board = nil)
    @game_board = board || Board.new
  end

  def get_xy
    xy = gets.chomp
    while ((xy.length != 2) || !(xy.match /[0-7][0-7]|88|99/))
      puts "Invalid coordinates. Try again."
      xy = gets.chomp
    end
    xy
  end

  def player_turn(player)
    
    puts "\n#{player.order_player}, #{player.color}\'s turn"
    while true
      puts "Choose the coordinates of the piece to move (xy), or write '88' to encastle left or '99' to encastle right"
      xy_origin = get_xy
      if xy_origin == "88"
        break if game_board.encastle_left(player)
        puts "It is not possible to encastle left."
        next
      elsif xy_origin == "99"
        break if game_board.encastle_right(player)
        puts "It is not possible to encastle right."
        next
      end
      coord_from = xy_origin.split('')
      if (game_board.board[coord_from[0].to_i][coord_from[1].to_i].nil?)
        puts "There's no piece to move at those coordinates. Try again."
        next
      elsif (game_board.board[coord_from[0].to_i][coord_from[1].to_i].color != player.color)
        puts "You can't move your opponent's pieces. Try again."
        next
      end 
      piece = game_board.board[coord_from[0].to_i][coord_from[1].to_i]
      game_board.find_possible_moves(piece)
      puts "Choose the coordinates of the place to move the piece to (xy)"
      xy_dest = get_xy
      coord_to = xy_dest.split('')
      if piece.possible_moves.include? ([coord_to[0].to_i, coord_to[1].to_i])    
        piece_at_dest = game_board.board[coord_to[0].to_i][coord_to[1].to_i]
        game_board.make_move(coord_from, coord_to)
        
        opponent = (@player1 == player) ? @player2 : @player1
        if game_board.checked?(opponent)
          puts "You can't make that move. You'll be in check."
          game_board.make_move(coord_to, coord_from, piece_at_dest)
          next
        end
        game_board.promote_pawn(coord_to) if (((piece.class == WhitePawn) || (piece.class == BlackPawn)) && ((coord_to[1] == "0") || (coord_to[1] == "7")))
        if game_board.checked?(player)
          if game_board.check_mate?(player)
            game_board.display_board
            puts player.color + " has won the game."
            return true
          end
          puts player.color + " has checked his opponent!"
        else
          #check for stalemate
          if game_board.check_mate?(player) #check if any possible move results in check while not being in check in the current position
            game_board.display_board
            puts "The game ended in a stalemate."
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
    game_board.display_board
    nil
  end

  def menu
    @player1 = Player.new("white", "player1")
    @player2 = Player.new("black", "player2")
    game_board.display_board
    loop do
      break if player_turn(@player1)
      break if player_turn(@player2)
    end
  end

end


g = Game.new
g.menu

