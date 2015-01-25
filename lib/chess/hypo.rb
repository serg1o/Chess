module Chess
	class Hypo < Piece
		attr_reader :moves
		# @param moves [Array<Array<Fixnum>]
		# @param color [String]
		def initialize color, moves
			super color
			@moves = moves
		end
	end
end
			
		