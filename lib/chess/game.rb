require "yaml"
module Chess
  class Game
    attr_accessor :board, :player1, :player2, :game_file, :next_to_play
    def initialize(board = Board.new)
      @board = board
    end

    def save_game
      Dir.mkdir("saved_games") unless Dir.exists?("saved_games")
      if @game_file.nil?
        list_files = Dir["saved_games/*"]
        list_ids = list_files.collect { |fname| fname.scan(/\d+/).join.to_i }
        new_id = list_ids.empty? ? 1 : list_ids.max + 1
        @game_file = "saved_games/game#{new_id}.txt"
      end
      File.open(@game_file, "w").write YAML::dump [self]
      puts "file saved as #{game_file}"
    end

    def load_game 
      list_files = Dir["saved_games/*"]
      list_ids = list_files.collect { |fname| fname.scan(/\d+/).join.to_i }
      if list_ids.empty?
        puts "There are no saved games to be loaded"
        return false
      end
      puts "Choose the id of the file to load: \n#{list_ids.inspect}"
      id_load = gets.chomp
      if File.exists? "saved_games/game#{id_load}.txt"
        values = YAML::load File.open("saved_games/game#{id_load}.txt", "r").readlines.join
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
      puts <<-HERE
#{block * 6}#{block * msg.length}#{block * 7}
#{block * 2}#{' ' * (msg.length + 9)}#{block * 2}
#{block * 2}     #{msg}    #{block * 2}
#{block * 2}#{' '* (msg.length + 9)}#{block * 2}
#{block * 6}#{block * msg.length}#{block * 7}
      HERE
    end

    def print_board_and_message(msg)
      board.display_board
      print_message msg
    end

    #verify if the player's king or rooks moved or if any of the opponents rooks was taken in order to invalidate the corresponding encastling move
    def check_rooks_king_moved(piece, player, opponent, coord_from, coord_to)
      if piece.class == King
        player.king_moved = true
      else
        player_first_rank = (player.color == BLACK) ? 0 : 7
        opponent_first_rank = 7 - player_first_rank
        player.queen_rook_moved = true if coord_from == [0, player_first_rank]
        player.king_rook_moved = true if coord_from == [7, player_first_rank]
        # case when player takes one of the opponent's rooks at their initial positions
        opponent.queen_rook_moved = true if coord_to == [0, opponent_first_rank]
        opponent.king_rook_moved = true if coord_to == [7, opponent_first_rank]
      end
    end

    def get_moves_and_score(mock_board, player, opponent)
      list_moves = Array.new
      mock_board.squares_iterator do |x, y|
        if !(mock_board.squares[x][y].nil?) && mock_board.squares[x][y].color == player.color
          mock_board.find_possible_moves(mock_board.squares[x][y], x, y).each do |m|
            p_taken, score = mock_board.make_move([x, y], m), 0
            unless p_taken.nil?
              p_taken_class = p_taken.class.to_s
              score = SCORES[p_taken_class]
              opponent_in_check = mock_board.in_check?(opponent)
              opponent_in_check_mate = mock_board.in_check_mate?(opponent) && opponent_in_check
              score += 1 if opponent_in_check && !opponent_in_check_mate
              score += 12 if opponent_in_check && opponent_in_check_mate
              score -= 10 if !opponent_in_check && opponent_in_check_mate
            end
            list_moves.push [score,[x, y], m] unless mock_board.in_check? player
            mock_board.make_move m, [x, y], p_taken
          end
        end
      end
      list_moves
    end

    def get_max_score(list)
      list.map {  |elem| elem[0] }.max || 0 #if list is empty return 0
    end

    def get_computer_move(board, player, opponent)
      mock_board = board.dup
      aux_list, m_board, opp, plr = Array.new, mock_board.dup, opponent.dup, player.dup
      get_moves_and_score(mock_board, player, opponent).each do |m|
        p_taken = m_board.make_move m[1], m[2]
        subtract_score = get_max_score get_moves_and_score m_board, opp, plr
        m_board.make_move m[2], m[1], p_taken
        aux_elem = m
        aux_elem[0] -= subtract_score
        aux_list.push aux_elem
      end
      aux_list.shuffle!
      pc_move, pc_move_score = [aux_list.first[1], aux_list.first[2]], aux_list.first[0]
      aux_list.each { |mv| pc_move, pc_move_score = [mv[1], mv[2]], mv[0] if m.first > pc_move_score  }
      return [pc_move[0].join, pc_move[1].join]
    end

    def get_xy
      loop do
        xy = gets.chomp
        if ((xy.length == 2) && (xy.match /[0-7][0-7]|88|99/)) || ((xy.length == 1) && (xy.match /s|S|q|Q/))
          return xy
        else
          board.display_board
          puts "\n\nInvalid input. Try again.\n\n\n"
        end
      end
    end

    def player_turn(player)
      if board.draw?
        print_message "The game ended in a tie."
        return true
      end
      opponent = (@player1 == player) ? @player2 : @player1
      loop do
        puts "\n#{player.order_player}, #{player.color}\'s turn"
        board.display_board
        puts <<-HERE
\nWrite 's' to save the game.
Write 'q' to exit the game without saving.
Choose the coordinates of the piece to move (xy),
or write '88' to encastle with the queen's rook or '99' to encastle with the king's rook.
        HERE
        sleep(1) if player.computer_player && opponent.computer_player
        comp_move = Array.new
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
          break if board.encastle_left player
          print_board_and_message "It is not possible to encastle with the queen's rook."
          next
        elsif xy_origin == "99"
          break if board.encastle_right player
          print_board_and_message "It is not possible to encastle with the king's rook."
          next
        end
        coord_from = xy_origin.split String.new
        coord_from = [coord_from[0].to_i, coord_from[1].to_i]
        if (board.squares[coord_from[0]][coord_from[1]].nil?)
          print_board_and_message "There's no piece to move at those coordinates. Try again."
          next
        elsif board.squares[coord_from[0]][coord_from[1]].color != player.color
          print_board_and_message "You can't move your opponent's pieces. Try again."
          next
        end
        piece = board.squares[coord_from[0]][coord_from[1]]
        board.find_possible_moves(piece, coord_from[0], coord_from[1])
        board.display_board
        puts "\n\nChoose the coordinates of the place to move the piece to (xy)\n\n\n"
        xy_dest = player.computer_player ? comp_move[1] : get_xy 
        coord_to = xy_dest.split String.new
        coord_to = [coord_to[0].to_i, coord_to[1].to_i]
        if piece.possible_moves.include? [coord_to[0], coord_to[1]]    
          piece_at_dest = board.make_move coord_from, coord_to    
          if board.in_check? player
            print_board_and_message "You can't make that move. You'll be in check."
            board.make_move coord_to, coord_from, piece_at_dest
            next
          end
          board.clear_enpassant player #revoke the possibility of making en passant moves
          board.enable_enpassant piece, coord_from, coord_to[0], coord_to[1] #if piece is a pawn and moves two squares check if opponent has won the right to an enpassant move
          board.promote_pawn(coord_to, player) if piece.class == Pawn && (coord_to[1].zero? || coord_to[1] == 7)
          board.update_pawn_hypo_moves piece, coord_to, coord_from[1]
          if board.in_check? opponent
            if board.in_check_mate? opponent
              print_board_and_message("Checkmate! #{player.color} player has won the game.")
              return true
            end
            print_message "#{opponent.color} king is in check!"
          else #check for stalemate
            if board.in_check_mate? opponent #check if any possible move results in check while not being in check in the current position
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
      puts "1 - Both players are humans"
      puts "2 - Player1 (white) is human and player2 (black) is the computer"
      puts "3 - Player2 (black) is human and player1 (white) is the computer"
      puts "4 - Play the computer against the computer (Warning: this may result in an infinite loop. Use Ctrl+C to terminate the program.)"
      choice = gets.chomp.downcase
      until choice.length == 1 && choice.match /[1-4]/
        puts "Invalid choice. Try again."
        choice = gets.chomp.downcase
      end
      choice_bool = (choice.to_i - 1).to_s(2).rjust(2,"0")
      @player1.computer_player = !(choice_bool[0].to_i).zero?
      @player2.computer_player = !(choice_bool[1].to_i).zero?
    end

    def menu
      @player1 = Player.new WHITE, "player1"
      @player2 = Player.new BLACK, "player2"
      @board.create_pieces
      if Dir.exists? "saved_games"
        puts "Do you want to load a saved game? (y/n)"
        load_saved = gets[0].downcase
        if load_saved == "y" && load_game
          if @next_to_play == BLACK
            return if player_turn @player2
            @next_to_play = @player1.color
          end
        else
          select_game_mode
        end
      else
        select_game_mode
      end
      loop do
        break if player_turn @player1
        @next_to_play = @player2.color
        break if player_turn @player2
        @next_to_play = @player1.color
      end
    end
  end
end
