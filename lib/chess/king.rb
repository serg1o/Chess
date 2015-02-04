module Chess
  class King < Hypo
    def initialize color
      super color, [	[	0, -1	], [	0, 1	], [	1, -1	], [	1, 1	], [	1, 0	], [	-1, -1	], [	-1, 1	], [	-1, 0	]	]
    end
  end
end
