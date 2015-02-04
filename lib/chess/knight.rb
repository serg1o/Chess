module Chess
  class Knight < Hypo
    def initialize color
      super color, [[2, 1], [2, -1], [1, 2], [1, -2], [-2, 1], [-2, -1], [-1, 2], [-1, -2]]
    end
  end
end
