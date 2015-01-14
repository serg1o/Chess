require_relative '../chess'
 
describe Game do

  before(:all) do
    @player1 = Player.new(WHITE, "player1")
    @player2 = Player.new(BLACK, "player2")
  end

  context "movement of piece" do
    context "white pawn" do
      context "with no pieces in front" do
        before(:each) do
          @board = Board.new
          @piece = Pawn.new(WHITE)
          @board.squares[4][6] = @piece
          @board.find_possible_moves_pawn(@piece, 4, 6)
          @game = Game.new(@board)
        end
        
        it "moves 1 squares on first move" do
          expect(@game.board.squares[4][6].possible_moves.include?([4, 5])).to eql(true)
        end

        it "moves 2 squares on first move" do
          expect(@game.board.squares[4][6].possible_moves.include?([4, 4])).to eql(true)
        end

        it "can't move 3 squares on first move" do
          expect(@game.board.squares[4][6].possible_moves.include?([4, 3])).to eql(false)
        end

        it "can't move backwards" do
          expect(@game.board.squares[4][6].possible_moves.include?([4, 7])).to eql(false)
        end
      end

      context "with pieces in front" do
        before(:each) do
          @board = Board.new
          @piece = Pawn.new(WHITE)
          @board.squares[4][6] = @piece
          @board.squares[4][5] = Knight.new(BLACK)
          @board.find_possible_moves_pawn(@piece, 4, 6)
          @game = Game.new(@board)
        end

        it "can't move 2 squares on first move" do
          expect(@game.board.squares[4][6].possible_moves.include?([4, 4])).to eql(false)
        end

        it "can't move 1 square" do
          expect(@game.board.squares[4][6].possible_moves.include?([4, 5])).to eql(false)
        end

      end

      context "with opponent piece two squares in front" do
        before(:each) do
          @board = Board.new
          @piece = Pawn.new(WHITE)
          @board.squares[4][6] = @piece
          @board.squares[4][4] = Knight.new(BLACK)
          @piece2 = Pawn.new(BLACK)
          @board.squares[0][1] = @piece2
          @board.squares[0][3] = Knight.new(WHITE)
          @board.find_possible_moves_pawn(@piece, 4, 6)
          @board.find_possible_moves_pawn(@piece2, 4, 4)
          @game = Game.new(@board)
        end

        it "white pawn can't take the opponent's piece" do
          expect(@game.board.squares[4][6].possible_moves.include?([4, 4])).to eql(false)
        end

        it "black pawn can't take the opponent's piece" do
          expect(@game.board.squares[0][1].possible_moves.include?([0, 3])).to eql(false)
        end
      end

      context "with pieces in the first square on a diagonal" do
        before(:each) do
          @board = Board.new
          @piece = Pawn.new(WHITE)
          @board.squares[4][6] = @piece
          @board.squares[5][5] = Knight.new(BLACK)
          @board.squares[3][5] = Queen.new(WHITE)
          @board.squares[3][7] = Bishop.new(BLACK)
          @board.find_possible_moves_pawn(@piece, 4, 6)
          @game = Game.new(@board)
        end

        it "can't take piece of same color" do
          expect(@game.board.squares[4][6].possible_moves.include?([3, 5])).to eql(false)
        end

        it "can't take piece behind of it" do
          expect(@game.board.squares[4][6].possible_moves.include?([3, 7])).to eql(false)
        end

        it "can take piece of different color" do
          expect(@game.board.squares[4][6].possible_moves.include?([5, 5])).to eql(true)
        end
      end

      context "after having moved once" do
        before(:each) do
          @board = Board.new
          @piece = Pawn.new(WHITE)
          @board.squares[4][7] = King.new(WHITE)
          @board.squares[4][0] = King.new(BLACK)
          @board.squares[4][6] = @piece
          @game = Game.new(@board)
          @game.player1 = Player.new(WHITE, "player1")
          @game.player2 = Player.new(BLACK, "player2")
          allow(@game).to receive(:gets) do
            @index ||= 0
            moves = ["46", "45"]
            if @index < 2
              resp = moves[@index]
              @index += 1
            else
              resp = "q"
            end
            resp
          end
          @game.player_turn(@game.player1)
        end
        
        it "moves 1 squares" do
          expect(@game.board.squares[4][5].possible_moves.include?([4, 4])).to eql(true)
        end

        it "can't move 2 squares" do
          expect(@game.board.squares[4][5].possible_moves.include?([4, 3])).to eql(false)
        end

        it "can't move in diagonal" do
          expect(@game.board.squares[4][5].possible_moves.include?([3, 4])).to eql(false)
        end

        it "can't move backwards" do
          expect(@game.board.squares[4][5].possible_moves.include?([4, 6])).to eql(false)
        end
      end
     
    end

    context "black pawn" do
      context "with no pieces in front" do
        before(:each) do
          @board = Board.new
          @piece = Pawn.new(BLACK)
          @board.squares[4][1] = @piece
          @board.find_possible_moves_pawn(@piece, 4, 1)
          @game = Game.new(@board)
        end
        
        it "moves 1 squares on first move" do
          expect(@game.board.squares[4][1].possible_moves.include?([4, 2])).to eql(true)
        end

        it "moves 2 squares on first move" do
          expect(@game.board.squares[4][1].possible_moves.include?([4, 3])).to eql(true)
        end

        it "can't move 3 squares on first move" do
          expect(@game.board.squares[4][1].possible_moves.include?([4, 4])).to eql(false)
        end

        it "can't move backwards" do
          expect(@game.board.squares[4][1].possible_moves.include?([4, 0])).to eql(false)
        end
      end

      context "with pieces in front" do
        before(:each) do
          @board = Board.new
          @piece = Pawn.new(BLACK)
          @board.squares[4][1] = @piece
          @board.squares[4][2] = Knight.new(WHITE)
          @board.find_possible_moves_pawn(@piece, 4 ,1)
          @game = Game.new(@board)
        end

        it "can't move 2 squares on first move" do
          expect(@game.board.squares[4][1].possible_moves.include?([4, 3])).to eql(false)
        end

        it "can't move 1 square" do
          expect(@game.board.squares[4][1].possible_moves.include?([4, 2])).to eql(false)
        end

      end

      context "with pieces in the first square on a diagonal" do
        before(:each) do
          @board = Board.new
          @piece = Pawn.new(BLACK)
          @board.squares[4][1] = @piece
          @board.squares[3][2] = Knight.new(WHITE)
          @board.squares[5][2] = Queen.new(BLACK)
          @board.squares[3][0] = Bishop.new(WHITE)
          @board.find_possible_moves_pawn(@piece, 4, 1)
          @game = Game.new(@board)
        end

        it "can't take piece of same color" do
          expect(@game.board.squares[4][1].possible_moves.include?([5, 2])).to eql(false)
        end

        it "can't take piece behind of it" do
          expect(@game.board.squares[4][1].possible_moves.include?([3, 0])).to eql(false)
        end

        it "can take piece of different color" do
          expect(@game.board.squares[4][1].possible_moves.include?([3, 2])).to eql(true)
        end
      end

      context "after having moved once" do
        before(:each) do
          @board = Board.new
          @piece = Pawn.new(BLACK)
          @board.squares[4][7] = King.new(WHITE)
          @board.squares[4][0] = King.new(BLACK)
          @board.squares[4][1] = @piece
          @game = Game.new(@board)
          @game.player1 = Player.new(WHITE, "player1")
          @game.player2 = Player.new(BLACK, "player2")
          allow(@game).to receive(:gets) do
            @index ||= 0
            moves = ["41", "43"]
            if @index < 2
              resp = moves[@index]
              @index += 1
            else
              resp = "q"
            end
            resp
          end
          @game.player_turn(@game.player2)
        end
        
        it "moves 1 squares" do
          expect(@game.board.squares[4][3].possible_moves.include?([4, 4])).to eql(true)
        end

        it "can't move 2 squares" do
          expect(@game.board.squares[4][3].possible_moves.include?([4, 5])).to eql(false)
        end

        it "can't move in diagonal" do
          expect(@game.board.squares[4][3].possible_moves.include?([5, 4])).to eql(false)
        end

        it "can't move backwards" do
          expect(@game.board.squares[4][3].possible_moves.include?([4, 2])).to eql(false)
        end
      end
     
    end

    context "rook" do
      before(:each) do
        @board = Board.new
        @piece = Rook.new(WHITE)
        @board.squares[4][3] = @piece
        @board.squares[4][1] = Queen.new(BLACK)
        @board.squares[2][3] = Pawn.new(WHITE)
        @board.find_possible_moves_rook(@piece, 4, 3)
        @game = Game.new(@board)
      end

      it "can't move out of the board" do
        expect(@game.board.squares[4][3].possible_moves.include?([8, 3])).to eql(false)
      end

      it "can't move in diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([5, 4])).to eql(false)
      end

      it "can move to the right" do
        expect(@game.board.squares[4][3].possible_moves.include?([7, 3])).to eql(true)
      end

      it "can move to the right one square" do
        expect(@game.board.squares[4][3].possible_moves.include?([5, 3])).to eql(true)
      end

      it "can't move to the position of a piece with the same color" do
        expect(@game.board.squares[4][3].possible_moves.include?([2, 3])).to eql(false)
      end

      it "can't move over a piece with the same color" do
        expect(@game.board.squares[4][3].possible_moves.include?([1, 3])).to eql(false)
      end

      it "can move to the position of a piece with a different color" do
        expect(@game.board.squares[4][3].possible_moves.include?([4, 1])).to eql(true)
      end

      it "can't move over a piece with a different color" do
        expect(@game.board.squares[4][3].possible_moves.include?([4, 0])).to eql(false)
      end
    end

    context "bishop" do
      before(:each) do
        @board = Board.new
        @piece = Bishop.new(WHITE)
        @board.squares[4][3] = @piece
        @board.squares[6][1] = Queen.new(BLACK)
        @board.squares[6][5] = Pawn.new(WHITE)
        @board.find_possible_moves_bishop(@piece, 4, 3)
        @game = Game.new(@board)
      end

      it "can't move out of the board" do
        expect(@game.board.squares[4][3].possible_moves.include?([8, 7])).to eql(false)
      end

      it "can't move in horizontal" do
        expect(@game.board.squares[4][3].possible_moves.include?([6, 3])).to eql(false)
      end

      it "can't move in vertical" do
        expect(@game.board.squares[4][3].possible_moves.include?([4, 2])).to eql(false)
      end

      it "can move in diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([0, 7])).to eql(true)
      end

      it "can move in diagonal one square" do
        expect(@game.board.squares[4][3].possible_moves.include?([3, 2])).to eql(true)
      end

      it "can't move to the position of a piece with the same color" do
        expect(@game.board.squares[4][3].possible_moves.include?([6, 5])).to eql(false)
      end

      it "can't move over a piece with the same color" do
        expect(@game.board.squares[4][3].possible_moves.include?([7, 6])).to eql(false)
      end

      it "can move to the position of a piece with a different color" do
        expect(@game.board.squares[4][3].possible_moves.include?([6, 1])).to eql(true)
      end

      it "can't move over a piece with a different color" do
        expect(@game.board.squares[4][3].possible_moves.include?([7, 0])).to eql(false)
      end
    end

    context "queen" do
      before(:each) do
        @board = Board.new
        @piece = Queen.new(BLACK)
        @board.squares[4][3] = @piece
        @board.squares[6][1] = King.new(BLACK)
        @board.squares[6][5] = Pawn.new(WHITE)
        @board.squares[4][2] = Pawn.new(BLACK)
        @board.squares[3][3] = Bishop.new(WHITE)
        @board.find_possible_moves_queen(@piece, 4, 3)
        @game = Game.new(@board)
      end

      it "can't move out of the board in a diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([0, -1])).to eql(false)
      end

      it "can't move two squares to the right and one up" do
        expect(@game.board.squares[4][3].possible_moves.include?([6, 2])).to eql(false)
      end

      it "can move in diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([0, 7])).to eql(true)
      end

      it "can move in diagonal one square" do
        expect(@game.board.squares[4][3].possible_moves.include?([3, 2])).to eql(true)
      end

      it "can't move to the position of a piece with the same color in a diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([6, 1])).to eql(false)
      end

      it "can't move over a piece with the same color in a diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([7, 0])).to eql(false)
      end

      it "can move to the position of a piece with a different color in a diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([6, 5])).to eql(true)
      end

      it "can't move over a piece with a different color in a diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([7, 6])).to eql(false)
      end

      it "can't move out of the board in a horizontal" do
        expect(@game.board.squares[4][3].possible_moves.include?([8, 3])).to eql(false)
      end

      it "can move to the right" do
        expect(@game.board.squares[4][3].possible_moves.include?([7, 3])).to eql(true)
      end

      it "can move to the right one square" do
        expect(@game.board.squares[4][3].possible_moves.include?([5, 3])).to eql(true)
      end

      it "can't move to the position of a piece with the same color in a vertical" do
        expect(@game.board.squares[4][3].possible_moves.include?([4, 2])).to eql(false)
      end

      it "can't move over a piece with the same color in a vertical" do
        expect(@game.board.squares[4][3].possible_moves.include?([4, 1])).to eql(false)
      end

      it "can move to the position of a piece with a different color in a horizontal" do
        expect(@game.board.squares[4][3].possible_moves.include?([3, 3])).to eql(true)
      end

      it "can't move over a piece with a different color in a horizontal" do
        expect(@game.board.squares[4][3].possible_moves.include?([2, 3])).to eql(false)
      end
    end

    context "king" do
      before(:each) do
        @board = Board.new
        @piece = King.new(BLACK)
        @board.squares[4][3] = @piece
        @board.squares[5][2] = Queen.new(BLACK)
        @board.squares[5][4] = Rook.new(WHITE)
        @board.squares[4][2] = Pawn.new(BLACK)
        @board.squares[3][3] = Bishop.new(WHITE)
        @board.find_possible_moves_generic(@piece, 4, 3)
        @game = Game.new(@board)
      end

      it "can't move two squares in diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([2, 1])).to eql(false)
      end

      it "can move in diagonal one square" do
        expect(@game.board.squares[4][3].possible_moves.include?([3, 2])).to eql(true)
      end

      it "can't move to the position of a piece with the same color in a diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([5, 2])).to eql(false)
      end

      it "can move to the position of a piece with a different color in a diagonal" do
        expect(@game.board.squares[4][3].possible_moves.include?([5, 4])).to eql(true)
      end

      it "can move one square to the right" do
        expect(@game.board.squares[4][3].possible_moves.include?([5, 3])).to eql(true)
      end

      it "can't move to the position of a piece with the same color in a vertical" do
        expect(@game.board.squares[4][3].possible_moves.include?([4, 2])).to eql(false)
      end

      it "can move to the position of a piece with a different color in a horizontal" do
        expect(@game.board.squares[4][3].possible_moves.include?([3, 3])).to eql(true)
      end

    end

    context "knight" do
      before(:each) do
        @board = Board.new
        @piece = Knight.new(BLACK)
        @board.squares[1][5] = @piece
        @board.squares[2][7] = King.new(BLACK)
        @board.squares[2][4] = Pawn.new(BLACK)
        @board.squares[0][3] = Bishop.new(WHITE)
        @board.find_possible_moves_generic(@piece, 1, 5)
        @game = Game.new(@board)
      end

      it "can't move out of the board" do
        expect(@game.board.squares[1][5].possible_moves.include?([-1, 6])).to eql(false)
      end

      it "can take piece of different color" do
        expect(@game.board.squares[1][5].possible_moves.include?([0, 3])).to eql(true)
      end

      it "can move over another piece" do
        expect(@game.board.squares[1][5].possible_moves.include?([2, 3])).to eql(true)
      end

      it "can move to an empty square" do
        expect(@game.board.squares[1][5].possible_moves.include?([3, 6])).to eql(true)
      end

      it "can't move to a square with a piece of same color" do
        expect(@game.board.squares[1][5].possible_moves.include?([2, 7])).to eql(false)
      end

      it "can't move in a horizontal" do
        expect(@game.board.squares[1][5].possible_moves.include?([0, 5])).to eql(false)
      end

      it "can't move in a vertical" do
        expect(@game.board.squares[1][5].possible_moves.include?([1, 4])).to eql(false)
      end

      it "can't move in a diagonal" do
        expect(@game.board.squares[1][5].possible_moves.include?([2, 6])).to eql(false)
      end

    end

  end

  context "white player encastling with king's rook" do
    before(:each) do
      @board = Board.new
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[7][7] = Rook.new(WHITE)
      @board.squares[0][7] = Rook.new(WHITE)
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end
    
    context " with pieces between king and rook" do
      before do
        @board.squares[6][7] = Knight.new(WHITE)
      end

      after do
        @board.squares[6][7] = nil
      end
   
      it "can't encastle when piece between king and rook" do
        expect(@game.board.encastle_right(@game.player1)).to eql(false)
      end
    end

    context " when king in check" do
      before do
        @board.squares[4][5] = Rook.new(BLACK)
      end
 
      after do
        @board.squares[4][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_right(@game.player1)).to eql(false)
      end
    end

    context " when adjacent square to the right of king is in check" do
      before do
        @board.squares[5][5] = Rook.new(BLACK)
      end

      after do
        @board.squares[5][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_right(@game.player1)).to eql(false)
      end
    end

    context " when second square to the right of king in check" do
      before do
        @board.squares[6][5] = Rook.new(BLACK)
      end

      after do
        @board.squares[6][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_right(@game.player1)).to eql(false)
      end
    end

    context " when king has moved" do
   
      it "can't encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["47", "37", "40", "50", "37", "47"]
          if @index < 6
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player1)
        @game.player_turn(@game.player2)
        @game.player_turn(@game.player1)
        expect(@game.board.encastle_right(@game.player1)).to eql(false)
      end
    end

    context " when king's rook has moved" do

      it "can't encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["77", "67", "67", "77"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player1)
        @game.player_turn(@game.player1)
        expect(@game.board.encastle_right(@game.player1)).to eql(false)
      end
    end

    context " when king's rook in check" do
      before do
        @board.squares[7][5] = Rook.new(BLACK)
      end

      after do
        @game.board.make_move([6, 7],[4, 7])
        @game.board.make_move([5, 7],[7, 7])
        @board.squares[7][5] = nil
      end
   
      it "can encastle" do
        expect(@game.board.encastle_right(@game.player1)).to eql(true)
        expect(@game.board.squares[6][7].class).to eql(King)
        expect(@game.board.squares[5][7].class).to eql(Rook)
      end
    end

    context "when no piece is between king and rook" do
      after do
        @game.board.make_move([6, 7],[4, 7])
        @game.board.make_move([5, 7],[7, 7])
      end

      it "can encastle" do
        expect(@game.board.encastle_right(@game.player1)).to eql(true)
        expect(@game.board.squares[6][7].class).to eql(King)
        expect(@game.board.squares[5][7].class).to eql(Rook)
      end
    end

    context "when the queen's rook has moved" do
      
      after do
        @game.board.make_move([6, 7],[4, 7])
        @game.board.make_move([5, 7],[7, 7])
      end

      it "can encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["07", "17", "17", "07"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player1)
        @game.player_turn(@game.player1)
        expect(@game.board.encastle_right(@game.player1)).to eql(true)
        expect(@game.board.squares[6][7].class).to eql(King)
        expect(@game.board.squares[5][7].class).to eql(Rook)
      end
    end
  end

  context "white player encastling with queen's rook" do
    before(:each) do
      @board = Board.new
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[7][7] = Rook.new(WHITE)
      @board.squares[0][7] = Rook.new(WHITE)
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end
    
    context " with pieces between king and rook" do
      before do
        @board.squares[2][7] = Knight.new(WHITE)
        
      end

      after do
        @board.squares[2][7] = nil
      end
   
      it "can't encastle when piece between king and rook" do
        expect(@game.board.encastle_left(@game.player1)).to eql(false)
      end
    end

    context " when king in check" do
      before do
        @board.squares[4][5] = Rook.new(BLACK)
        
      end
 
      after do
        @board.squares[4][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_left(@game.player1)).to eql(false)
      end
    end

    context " when adjacent square to the left of king is in check" do
      before do
        @board.squares[3][5] = Rook.new(BLACK)
        
      end

      after do
        @board.squares[3][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_left(@game.player1)).to eql(false)
      end
    end

    context " when second square to the left of king in check" do
      before do
        @board.squares[2][5] = Rook.new(BLACK)
        
      end

      after do
        @board.squares[2][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_left(@game.player1)).to eql(false)
      end
    end

    context " when third square to the left of king in check" do
      before do
        @board.squares[1][5] = Rook.new(BLACK)
        
      end

      after do
        @board.squares[1][5] = nil
      end
   
      it "can encastle" do
        expect(@game.board.encastle_left(@game.player1)).to eql(true)
      end
    end

    context " when king has moved" do
   
      it "can't encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["47", "37", "37", "47"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player1)
        @game.player_turn(@game.player1)
        expect(@game.board.encastle_left(@game.player1)).to eql(false)
      end
    end

    context " when queen's rook has moved" do

      it "can't encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["07", "17", "17", "07"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player1)
        @game.player_turn(@game.player1)
        expect(@game.board.encastle_left(@game.player1)).to eql(false)
      end
    end

    context " when queen's rook in check" do
      before do
        @board.squares[0][5] = Rook.new(BLACK)
        
      end

      after do
        @game.board.make_move([2, 7],[4, 7])
        @game.board.make_move([3, 7],[0, 7])
        @board.squares[0][5] = nil
      end
   
      it "can encastle" do
        expect(@game.board.encastle_left(@game.player1)).to eql(true)
        expect(@game.board.squares[2][7].class).to eql(King)
        expect(@game.board.squares[3][7].class).to eql(Rook)
      end
    end

    context "when no piece is between king and rook" do
      after do
        @game.board.make_move([2, 7],[4, 7])
        @game.board.make_move([3, 7],[0, 7])
      end

      it "can encastle" do
        expect(@game.board.encastle_left(@game.player1)).to eql(true)
        expect(@game.board.squares[2][7].class).to eql(King)
        expect(@game.board.squares[3][7].class).to eql(Rook)
      end
    end

    context "when the king's rook has moved" do
    
      after do
        @game.board.make_move([2, 7],[4, 7])
        @game.board.make_move([3, 7],[0, 7])
      end

      it "can encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["77", "67", "67", "77"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player1)
        @game.player_turn(@game.player1)

        expect(@game.board.encastle_left(@game.player1)).to eql(true)
        expect(@game.board.squares[2][7].class).to eql(King)
        expect(@game.board.squares[3][7].class).to eql(Rook)
      end
    end

  end


  context "black player encastling with king's rook" do
    before(:each) do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[7][0] = Rook.new(BLACK)
      @board.squares[0][0] = Rook.new(BLACK)
      
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end
    
    context " with pieces between king and rook" do
      before do
        @board.squares[6][0] = Knight.new(WHITE)
        
      end

      after do
        @board.squares[6][0] = nil
      end
   
      it "can't encastle when piece between king and rook" do
        expect(@game.board.encastle_right(@game.player2)).to eql(false)
      end
    end

    context " when king in check" do
      before do
        @board.squares[4][5] = Rook.new(WHITE)
        
      end
 
      after do
        @board.squares[4][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_right(@game.player2)).to eql(false)
      end
    end

    context " when adjacent square to the right of king is in check" do
      before do
        @board.squares[5][5] = Rook.new(WHITE)
        
      end

      after do
        @board.squares[5][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_right(@game.player2)).to eql(false)
      end
    end

    context " when second square to the right of king in check" do
      before do
        @board.squares[6][5] = Rook.new(WHITE)
        
      end

      after do
        @board.squares[6][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_right(@game.player2)).to eql(false)
      end
    end

    context " when king has moved" do
   
      it "can't encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["40", "41", "41", "40"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player2)
        @game.player_turn(@game.player2)
        expect(@game.board.encastle_right(@game.player2)).to eql(false)
      end
    end

    context " when king's rook has moved" do

      it "can't encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["70", "71", "71", "70"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player2)
        @game.player_turn(@game.player2)
        expect(@game.board.encastle_right(@game.player2)).to eql(false)
      end
    end

    context " when king's rook in check" do
      before do
        @board.squares[7][5] = Rook.new(WHITE)
        
      end

      after do
        @game.board.make_move([6, 0],[4, 0])
        @game.board.make_move([5, 0],[7, 0])
        @board.squares[7][5] = nil
      end
   
      it "can encastle" do
        expect(@game.board.encastle_right(@game.player2)).to eql(true)
        expect(@game.board.squares[6][0].class).to eql(King)
        expect(@game.board.squares[5][0].class).to eql(Rook)
      end
    end

    context "when no piece is between king and rook" do
      after do
        @game.board.make_move([6, 0],[4, 0])
        @game.board.make_move([5, 0],[7, 0])
      end

      it "can encastle" do
        expect(@game.board.encastle_right(@game.player2)).to eql(true)
        expect(@game.board.squares[6][0].class).to eql(King)
        expect(@game.board.squares[5][0].class).to eql(Rook)
      end
    end

    context "when the queen's rook has moved" do
      
      after do
        @game.board.make_move([6, 0],[4, 0])
        @game.board.make_move([5, 0],[7, 0])
      end

      it "can encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["00", "01", "01", "00"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player2)
        @game.player_turn(@game.player2)
        expect(@game.board.encastle_right(@game.player2)).to eql(true)
        expect(@game.board.squares[6][0].class).to eql(King)
        expect(@game.board.squares[5][0].class).to eql(Rook)
      end
    end

  end

  context "black player encastling with queen's rook" do
    before(:each) do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[7][0] = Rook.new(BLACK)
      @board.squares[0][0] = Rook.new(BLACK)
      
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end
    
    context " with pieces between king and rook" do
      before do
        @board.squares[2][0] = Knight.new(WHITE)
        
      end

      after do
        @board.squares[2][0] = nil
      end
   
      it "can't encastle when piece between king and rook" do
        expect(@game.board.encastle_left(@game.player2)).to eql(false)
      end
    end

    context " when king in check" do
      before do
        @board.squares[4][5] = Rook.new(WHITE)
        
      end
 
      after do
        @board.squares[4][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_left(@game.player2)).to eql(false)
      end
    end

    context " when adjacent square to the left of king is in check" do
      before do
        @board.squares[3][5] = Rook.new(WHITE)
        
      end

      after do
        @board.squares[3][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_left(@game.player2)).to eql(false)
      end
    end

    context " when second square to the left of king in check" do
      before do
        @board.squares[2][5] = Rook.new(WHITE)
        
      end

      after do
        @board.squares[2][5] = nil
      end
   
      it "can't encastle" do
        expect(@game.board.encastle_left(@game.player2)).to eql(false)
      end
    end

    context " when third square to the left of king in check" do
      before do
        @board.squares[1][5] = Rook.new(WHITE)
        
      end

      after do
        @board.squares[1][5] = nil
      end
   
      it "can encastle" do
        expect(@game.board.encastle_left(@game.player2)).to eql(true)
      end
    end

    context " when king has moved" do
   
      it "can't encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["40", "41", "41", "40"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player2)
        @game.player_turn(@game.player2)
        expect(@game.board.encastle_left(@game.player2)).to eql(false)
      end
    end

    context " when queen's rook has moved" do

      it "can't encastle" do

       allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["00", "01", "01", "00"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player2)
        @game.player_turn(@game.player2)
        expect(@game.board.encastle_left(@game.player2)).to eql(false)
      end
    end

    context " when queen's rook in check" do
      before do
        @board.squares[0][5] = Rook.new(WHITE)
        
      end

      after do
        @game.board.make_move([2, 0],[4, 0])
        @game.board.make_move([3, 0],[0, 0])
        @board.squares[0][5] = nil
      end
   
      it "can encastle" do
        expect(@game.board.encastle_left(@game.player2)).to eql(true)
        expect(@game.board.squares[2][0].class).to eql(King)
        expect(@game.board.squares[3][0].class).to eql(Rook)
      end
    end

    context "when no piece is between king and rook" do
      after do
        @game.board.make_move([2, 0],[4, 0])
        @game.board.make_move([3, 0],[0, 0])
      end

      it "can encastle" do
        expect(@game.board.encastle_left(@game.player2)).to eql(true)
        expect(@game.board.squares[2][0].class).to eql(King)
        expect(@game.board.squares[3][0].class).to eql(Rook)
      end
    end

    context "when the king's rook has moved" do

      after do
        @game.board.make_move([2, 0],[4, 0])
        @game.board.make_move([3, 0],[0, 0])
      end

      it "can encastle" do
        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["70", "71", "71", "70"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@game.player2)
        @game.player_turn(@game.player2)
        expect(@game.board.encastle_left(@game.player2)).to eql(true)
        expect(@game.board.squares[2][0].class).to eql(King)
        expect(@game.board.squares[3][0].class).to eql(Rook)
      end
    end

  end

  context "ends in a stalemate" do
    before do
      @board = Board.new
      @board.squares[7][0] = King.new(WHITE)
      @board.squares[6][2] = Queen.new(BLACK)
      @board.squares[5][2] = King.new(BLACK)
      
      @game = Game.new(@board)
    end

    it "white cannot move" do
      #check_mate_by? doesn't verify if the opponents king is in check but only if he can't move to a position not in check
      expect(@game.board.in_check_mate?(@player1)).to eql(true)
      expect(@game.board.in_check?(@player1)).to eql(false)
    end
  end

  context "ends in a check mate" do
    before do
      @board = Board.new
      @board.squares[7][0] = King.new(WHITE)
      @board.squares[6][2] = Queen.new(BLACK)
      @board.squares[5][2] = King.new(BLACK)
      @board.squares[5][1] = Knight.new(BLACK)
      
      @game = Game.new(@board)
    end

    it "white is checkmated" do
      expect(@game.board.in_check_mate?(@player1)).to eql(true)
      expect(@game.board.in_check?(@player1)).to eql(true)
    end
  end

  context "white king in check" do
    before do
      @board = Board.new
      @board.squares[7][0] = King.new(WHITE)
      @board.squares[6][2] = Queen.new(BLACK)
      @board.squares[5][2] = King.new(BLACK)
      
      @game = Game.new(@board)
    end

    it "white cannot move" do
      expect(@game.board.in_check_mate?(@player1)).to eql(true)
      expect(@game.board.in_check?(@player1)).to eql(false)
    end
  end

  context "taking pawn en passant" do
    before(:each) do
      @board = Board.new
      @board.squares[7][3] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[7][4] = Pawn.new(BLACK)
      @board.squares[6][6] = Pawn.new(WHITE)
      @board.squares[6][1] = Queen.new(WHITE)
      
      @game = Game.new(@board)
      @game.player1 = @player1
      @game.player2 = @player2
    end

    context "when king is in check" do

      it "takes opponent's pawn en passant" do

        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["66", "64"]
          if @index < 2
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@player1)
        
        expect(@game.board.in_check_mate?(@player2)).to eql(false)
        expect(@game.board.in_check?(@player2)).to eql(true)
        expect(@game.board.squares[7][4].possible_moves.include?([6, 5])).to eql(true)
      end
    end

    context "when pawn to be taken is to the left" do
      before do
        @game.board.squares[5][1] = Pawn.new(BLACK)
        @game.board.squares[4][3] = Pawn.new(WHITE)
      end

      it "takes opponent's pawn en passant" do

        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["51", "53", "43", "52"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end
        @game.player_turn(@player2)
        
        @game.player_turn(@player1)
        
        expect(@game.board.squares[5][3]).to eql(nil)
      end
    end

    context "when pawn to be taken is to the right" do
      before do
        @game.board.squares[3][1] = Pawn.new(BLACK)
        @game.board.squares[4][3] = Pawn.new(WHITE)
      end

      it "takes opponent's pawn en passant" do

        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["31", "33", "43", "32"]
          if @index < 4
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end
        @game.player_turn(@player2)
        
        @game.player_turn(@player1)
        
        expect(@game.board.squares[3][3]).to eql(nil)
      end
    end

    context "when pawn is not taken immediately after having moved two squares" do
      before do
        @game.board.squares[3][1] = Pawn.new(BLACK)
        @game.board.squares[4][3] = Pawn.new(WHITE)
      end

      it "can't take the opponent's pawn en passant" do

        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["31", "33", "47", "57", "74", "75"]
          if @index < 6
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end

        @game.player_turn(@player2)
        
        @game.player_turn(@player1)
        
        @game.player_turn(@player2)
        
        
        expect(@game.board.squares[4][3].possible_moves.include?([3, 2])).to eql(false)
      end
    end


   context "when the piece that made a move of two squares is not a pawn" do
      before do
        @game.board.squares[5][1] = Rook.new(BLACK)
        @game.board.squares[4][3] = Pawn.new(WHITE)
       
      end

      it "can't take the rook en passant" do

        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["51", "53"]
          if @index < 2
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end
        @game.player_turn(@player2)
        
        expect(@game.board.squares[4][3].possible_moves.include?([5, 2])).to eql(false)
      end
    end

    context "when pawn to be taken only moved one square" do
      before do
        @game.board.squares[5][2] = Pawn.new(BLACK)
        @game.board.squares[4][3] = Pawn.new(WHITE)
      end

      it "can't take the opponent's pawn en passant" do

        allow(@game).to receive(:gets) do
          @index ||= 0
          moves = ["52", "53"]
          if @index < 2
            resp = moves[@index]
            @index += 1
          else
            resp = "q"
          end
          resp
        end
        @game.player_turn(@player2)
        
        expect(@game.board.squares[4][3].possible_moves.include?([5, 2])).to eql(false)
      end
    end
  end

  context "when white player's queen rook moves to king's rook column" do
    before do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[0][5] = Rook.new(WHITE)
      @board.squares[7][7] = Rook.new(WHITE)
      
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end

    it "encastling is possible" do
       allow(@game).to receive(:gets) do
        @index ||= 0
        moves = ["05", "75"]
        if @index < 2
          resp = moves[@index]
          @index += 1
        else
          resp = "q"
        end
        resp
      end

      @game.player_turn(@game.player1)
      
      expect(@game.board.encastle_right(@game.player1)).to eql(true)
    end
  end

  context "when white player's king rook moves to queen's rook column" do
    before do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[0][7] = Rook.new(WHITE)
      @board.squares[7][5] = Rook.new(WHITE)
      
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end

    it "encastling is possible" do
       allow(@game).to receive(:gets) do
        @index ||= 0
        moves = ["75", "05", "40", "41", "05", "65"]
        if @index < 6
          resp = moves[@index]
          @index += 1
        else
          resp = "q"
        end
        resp
      end

      @game.player_turn(@game.player1)
      
      @game.player_turn(@game.player2)
      
      @game.player_turn(@game.player1)
      
      expect(@game.board.encastle_left(@game.player1)).to eql(true)
    end
  end



  context "when black player's queen rook moves to king's rook column" do
    before do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[7][0] = Rook.new(BLACK)
      @board.squares[0][2] = Rook.new(BLACK)
      
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end

    it "encastling is possible" do
       allow(@game).to receive(:gets) do
        @index ||= 0
        moves = ["02", "72"]
        if @index < 2
          resp = moves[@index]
          @index += 1
        else
          resp = "q"
        end
        resp
      end

      @game.player_turn(@game.player2)
      
      expect(@game.board.encastle_right(@game.player2)).to eql(true)
    end
  end

  context "when black player's king rook moves to queen's rook column" do
    before do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[0][0] = Rook.new(BLACK)
      @board.squares[7][2] = Rook.new(BLACK)
      
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end

    it "encastling is possible" do
       allow(@game).to receive(:gets) do
        @index ||= 0
        moves = ["72", "02", "47", "57", "02", "12"]
        if @index < 6
          resp = moves[@index]
          @index += 1
        else
          resp = "q"
        end
        resp
      end

      @game.player_turn(@game.player2)
      
      @game.player_turn(@game.player1)
      
      @game.player_turn(@game.player2)
      
      expect(@game.board.encastle_left(@game.player2)).to eql(true)
    end
  end


  context "when white player's king rook is taken" do
    before do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[6][5] = Knight.new(BLACK)
      @board.squares[7][7] = Rook.new(WHITE)
      
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end

    it "encastling with king's rook is not possible" do
       allow(@game).to receive(:gets) do
        @index ||= 0
        moves = ["65", "77"]
        if @index < 2
          resp = moves[@index]
          @index += 1
        else
          resp = "q"
        end
        resp
      end

      @game.player_turn(@game.player2)
      
      expect(@game.board.encastle_right(@game.player1)).to eql(false)
    end
  end

  context "when white player's queen rook is taken" do
    before do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[0][7] = Rook.new(WHITE)
      @board.squares[7][7] = Rook.new(WHITE)
      @board.squares[1][6] = Bishop.new(BLACK)
      
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end

    it "encastling with queen's rook is not possible" do
       allow(@game).to receive(:gets) do
        @index ||= 0
        moves = ["16", "07", "77", "76", "07", "34"]
        if @index < 6
          resp = moves[@index]
          @index += 1
        else
          resp = "q"
        end
        resp
      end

      @game.player_turn(@game.player2)
      
      @game.player_turn(@game.player1)
      
      @game.player_turn(@game.player2)
      
      expect(@game.board.encastle_left(@game.player1)).to eql(false)
    end
  end


   context "when black player's king rook is taken" do
    before do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[6][2] = Knight.new(WHITE)
      @board.squares[7][0] = Rook.new(BLACK)
      
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end

    it "encastling with king's rook is not possible" do
       allow(@game).to receive(:gets) do
        @index ||= 0
        moves = ["62", "70"]
        if @index < 2
          resp = moves[@index]
          @index += 1
        else
          resp = "q"
        end
        resp
      end

      @game.player_turn(@game.player1)
      
      expect(@game.board.encastle_right(@game.player2)).to eql(false)
    end
  end

  context "when black player's queen rook is taken" do
    before do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @board.squares[0][0] = Rook.new(BLACK)
      @board.squares[7][0] = Rook.new(BLACK)
      @board.squares[1][1] = Bishop.new(WHITE)
      
      @game = Game.new(@board)
      @game.player1 = Player.new(WHITE, "player1")
      @game.player2 = Player.new(BLACK, "player2")
    end

    it "encastling with queen's rook is not possible" do
       allow(@game).to receive(:gets) do
        @index ||= 0
        moves = ["11", "00", "70", "71", "00", "55"]
        if @index < 6
          resp = moves[@index]
          @index += 1
        else
          resp = "q"
        end
        resp
      end

      @game.player_turn(@game.player1)
      
      @game.player_turn(@game.player2)
      
      @game.player_turn(@game.player1)
      
      expect(@game.board.encastle_left(@game.player2)).to eql(false)
    end
  end

  context "Test tied game" do
    before(:each) do
      @board = Board.new
      @board.squares[4][0] = King.new(BLACK)
      @board.squares[4][7] = King.new(WHITE)
      @game = Game.new(@board)
    end
      
    it "2 lone kings result in a draw" do
      expect(@game.board.draw?).to eql(true)
    end

    it "2 kings and a white Knight result in a draw" do
      @game.board.squares[0][0] = Knight.new(WHITE)
      expect(@game.board.draw?).to eql(true)
    end

    it "2 kings and two white Knights result in a draw" do
      @game.board.squares[0][0] = Knight.new(WHITE)
      @game.board.squares[0][1] = Knight.new(WHITE)
      expect(@game.board.draw?).to eql(true)
    end

    it "2 kings and 3 white Knights does not result in a draw" do
      @game.board.squares[0][0] = Knight.new(WHITE)
      @game.board.squares[0][1] = Knight.new(WHITE)
      @game.board.squares[0][2] = Knight.new(WHITE)
      expect(@game.board.draw?).to eql(false)
    end

    it "2 kings and a black Knight result in a draw" do
      @game.board.squares[0][0] = Knight.new(BLACK)
      expect(@game.board.draw?).to eql(true)
    end

    it "2 kings and two black Knights result in a draw" do
      @game.board.squares[0][0] = Knight.new(BLACK)
      @game.board.squares[0][1] = Knight.new(BLACK)
      expect(@game.board.draw?).to eql(true)
    end

    it "2 kings and 3 black Knights does not result in a draw" do
      @game.board.squares[0][0] = Knight.new(BLACK)
      @game.board.squares[0][1] = Knight.new(BLACK)
      @game.board.squares[0][2] = Knight.new(BLACK)
      expect(@game.board.draw?).to eql(false)
    end

    it "2 kings, 1 black Knight and 1 white Knight result in a draw" do
      @game.board.squares[0][0] = Knight.new(BLACK)
      @game.board.squares[0][1] = Knight.new(WHITE)
      expect(@game.board.draw?).to eql(true)
    end

    it "2 kings and 2 black Knights and 1 white knight result in a draw" do
      @game.board.squares[0][0] = Knight.new(BLACK)
      @game.board.squares[0][1] = Knight.new(BLACK)
      @game.board.squares[0][2] = Knight.new(WHITE)
      expect(@game.board.draw?).to eql(true)
    end

    it "2 kings and 1 black Knight and 2 white knights result in a draw" do
      @game.board.squares[0][0] = Knight.new(BLACK)
      @game.board.squares[0][1] = Knight.new(WHITE)
      @game.board.squares[0][2] = Knight.new(WHITE)
      expect(@game.board.draw?).to eql(true)
    end

    it "2 kings and 2 black Knights, 1 white knight and 1 white bishop does not result in a draw" do
      @game.board.squares[0][0] = Knight.new(BLACK)
      @game.board.squares[0][1] = Knight.new(BLACK)
      @game.board.squares[0][2] = Knight.new(WHITE)
      @game.board.squares[1][2] = Bishop.new(WHITE)
      expect(@game.board.draw?).to eql(false)
    end

    it "2 kings and 1 black Knight, 1 white knight and 1 black bishop does not result in a draw" do
      @game.board.squares[0][0] = Knight.new(BLACK)
      @game.board.squares[0][1] = Knight.new(WHITE)
      @game.board.squares[0][2] = Bishop.new(BLACK)
      expect(@game.board.draw?).to eql(false)
    end

    it "2 kings and 1 white Knight and 1 black bishop result in a draw" do
      @game.board.squares[0][1] = Knight.new(WHITE)
      @game.board.squares[0][2] = Bishop.new(BLACK)
      expect(@game.board.draw?).to eql(true)
    end

    it "2 kings and 1 black Knight and 1 white bishop result in a draw" do
      @game.board.squares[0][1] = Knight.new(BLACK)
      @game.board.squares[0][2] = Bishop.new(WHITE)
      expect(@game.board.draw?).to eql(true)
    end

    it "2 kings and 1 black Knight and 1 black bishop does not result in a draw" do
      @game.board.squares[0][1] = Knight.new(BLACK)
      @game.board.squares[0][2] = Bishop.new(BLACK)
      expect(@game.board.draw?).to eql(false)
    end

    it "2 kings and 1 WHITE Knight and 1 WHITE bishop does not result in a draw" do
      @game.board.squares[0][1] = Knight.new(WHITE)
      @game.board.squares[0][2] = Bishop.new(WHITE)
      expect(@game.board.draw?).to eql(false)
    end

    it "2 kings and a black pawn does not result in a draw" do
      @game.board.squares[0][6] = Pawn.new(BLACK)
      expect(@game.board.draw?).to eql(false)
    end
   
    it "2 kings and a white pawn does not result in a draw" do
      @game.board.squares[0][6] = Pawn.new(WHITE)
      expect(@game.board.draw?).to eql(false)
    end

    it "2 kings and a black rook does not result in a draw" do
      @game.board.squares[0][6] = Rook.new(BLACK)
      expect(@game.board.draw?).to eql(false)
    end
   
    it "2 kings and a white rook does not result in a draw" do
      @game.board.squares[0][6] = Rook.new(WHITE)
      expect(@game.board.draw?).to eql(false)
    end

    it "2 kings and a black queen does not result in a draw" do
      @game.board.squares[0][6] = Queen.new(BLACK)
      expect(@game.board.draw?).to eql(false)
    end
   
    it "2 kings and a white queen does not result in a draw" do
      @game.board.squares[0][6] = Queen.new(WHITE)
      expect(@game.board.draw?).to eql(false)
    end

  end

end

