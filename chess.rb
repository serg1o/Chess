class Player
  attr_accessor :name, :color, :order_player
  def initialize(name, color, order)
    @name = name
    @order_player = order #player1, player2 etc
    @color = color
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

  def find_possible_moves_black_pawn(piece)
    result = []
    piece.hypo_moves = [[0, 1], [1, 1], [-1, 1]] if piece.position_y != 1
    
    piece.hypo_moves.each do |hm|
      x = piece.position_x + hm[0]
      y = piece.position_y + hm[1]
      result.push([x, y]) if (x.between?(0, 7) && y.between?(0, 7) && (board[x][y] == nil) && (hm[0] == 0))
      result.push([x, y]) if (x.between?(0, 7) && y.between?(0, 7) && (board[x][y] != nil) && (board[x][y].color != piece.color) && (hm[0] != 0))
    end
    piece.possible_moves = result
  end

  def find_possible_moves_white_pawn(piece)
    result = []
    piece.hypo_moves = [[0, -1], [1, -1], [-1, -1]] if piece.position_y != 6
    
    piece.hypo_moves.each do |hm|
      x = piece.position_x + hm[0]
      y = piece.position_y + hm[1]
      result.push([x, y]) if (x.between?(0, 7) && y.between?(0, 7) && (board[x][y] == nil) && (hm[0] == 0))
      result.push([x, y]) if (x.between?(0, 7) && y.between?(0, 7) && (board[x][y] != nil) && (board[x][y].color != piece.color) && (hm[0] != 0))
    end
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
          saved_move = {}
          coord_to = mov
          coord_from = [x, y]
          saved_move[:piece_at_dest] = board[coord_to[0].to_i][coord_to[1].to_i]
          board[coord_to[0].to_i][coord_to[1].to_i] = board[coord_from[0].to_i][coord_from[1].to_i]
          board[coord_to[0].to_i][coord_to[1].to_i].position_x = coord_to[0].to_i
          board[coord_to[0].to_i][coord_to[1].to_i].position_y = coord_to[1].to_i
          board[coord_from[0].to_i][coord_from[1].to_i] = nil
          temp = checked?(player) 
          board[coord_from[0].to_i][coord_from[1].to_i] = board[coord_to[0].to_i][coord_to[1].to_i]
          board[coord_from[0].to_i][coord_from[1].to_i].position_x = coord_from[0].to_i
          board[coord_from[0].to_i][coord_from[1].to_i].position_y = coord_from[1].to_i
          board[coord_to[0].to_i][coord_to[1].to_i] = saved_move[:piece_at_dest]
          return false if !temp
        end
      end
    end
    return true
  end

  def get_piece_code(piece)
    return piece.color[0] + "Pn" if ((piece.class == WhitePawn) || (piece.class == BlackPawn))
    return piece.color[0] + piece.class.to_s[0] + piece.class.to_s[-1]
  end

  def display_board
    puts "\n       0     1     2     3     4     5     6     7 "
    puts "    -------------------------------------------------"
    (0..7).each do |c_index|  
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
    while ((xy.length != 2) || !(xy.match /[0-7][0-7]/))
      puts "Invalid coordinates. Try again"
      xy = gets.chomp
    end
    xy
  end

  def player_turn(player)
    
    puts "\n#{player.order_player} '#{player.name}' turn"
    while true
      puts "choose the coordinates of the piece to move (xy)"
      xy_origin = get_xy
      coord_from = xy_origin.split('')
      puts coord_from.inspect
      if (game_board.board[coord_from[0].to_i][coord_from[1].to_i].nil?)
        puts "There's no piece to move at those coordinates. Try again."
        next
      elsif (game_board.board[coord_from[0].to_i][coord_from[1].to_i].color != player.color)
        puts "You can't move your opponent's pieces. Try again."
        next
      end 
      piece = game_board.board[coord_from[0].to_i][coord_from[1].to_i]
      game_board.find_possible_moves(piece)
      puts "choose the coordinates of the place to move the piece to (xy)"
      xy_dest = get_xy
      coord_to = xy_dest.split('')
      if piece.possible_moves.include? ([coord_to[0].to_i, coord_to[1].to_i])
        saved_move = {}
        saved_move[:piece_at_dest] = game_board.board[coord_to[0].to_i][coord_to[1].to_i]
        game_board.board[coord_to[0].to_i][coord_to[1].to_i] = game_board.board[coord_from[0].to_i][coord_from[1].to_i]
        game_board.board[coord_to[0].to_i][coord_to[1].to_i].position_x = coord_to[0].to_i
        game_board.board[coord_to[0].to_i][coord_to[1].to_i].position_y = coord_to[1].to_i
        game_board.board[coord_from[0].to_i][coord_from[1].to_i] = nil
        opponent = (@player1 == player) ? @player2 : @player1
        if game_board.checked?(opponent)
          puts "You can't make that move. You'll be in check."
          game_board.board[coord_from[0].to_i][coord_from[1].to_i] = game_board.board[coord_to[0].to_i][coord_to[1].to_i]
          game_board.board[coord_from[0].to_i][coord_from[1].to_i].position_x = coord_from[0].to_i
          game_board.board[coord_from[0].to_i][coord_from[1].to_i].position_y = coord_from[1].to_i
          game_board.board[coord_to[0].to_i][coord_to[1].to_i] = saved_move[:piece_at_dest]
          next
        end
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
        break
      else
        puts "That move is not allowed. Chose again."
      end
    end
    game_board.display_board
    nil
  end

  def menu
    puts "Name of player1:"
    name_p1 = gets.chomp
    puts "Name of player2:"
    name_p2 = gets.chomp
    @player1 = Player.new(name_p1, "white", "player1")
    @player2 = Player.new(name_p2, "black", "player2")
    game_board.display_board
    loop do
      break if player_turn(@player1)
      break if player_turn(@player2)
    end
  end

end


g = Game.new
g.menu

