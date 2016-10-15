# https://codeiq.jp/challenge/2925

module Maze
  class Maze
    MAP_RANGE = [0..5, 0..4]

    attr_reader :maze_map # "map" is reserved by Ruby.

    def initialize(str)
      @maze_map = str.split("/").map{|m| m.split("")}.transpose
    end

    def within_range?(pos)
      MAP_RANGE[0].include?(pos[0]) && MAP_RANGE[1].include?(pos[1])  # 範囲チェックはRangeオブジェクトを使う。
    end

    def pos(str)
      @maze_map.flatten.index(str).divmod(@maze_map.count-1)  # 2次元配列の値を検索
    end
  end

  class Route
    NEXT_POS = [[-1, 0], [1, 0], [0, -1], [0,1]]
    LOOP_LIMIT = 10000

    attr_reader :cur_pos, :pos_history, :val_history

    def initialize(pos, previous=nil)
      @cur_pos = pos
      @pos_history = previous ? previous.pos_history.dup.push(previous.cur_pos) : []
      @val_history = previous ? previous.val_history.dup.push(previous.cur_val) : []
    end

    def to_goal
      nexts = [self]
      (0..LOOP_LIMIT).each do
        nexts = nexts.map{|n| n.next}.flatten
        return nil if nexts.empty?
        nexts.each do |n|
          return n if (n.cur_val == @@goal) && ((n.val_history - ["."]) == @@path )
        end
      end
      raise "Loop limit !"
    end

    protected

    def next
      @next ||= NEXT_POS.map{|p|
        pos = self.sum(*p)
        self.class.new(pos, self)
      }.select{|n| n.valid_pos?}
    end

    def sum(x, y)
      [@cur_pos[0] + x, @cur_pos[1] + y]
    end

    def cur_val
      @@maze.maze_map[self.cur_pos[0]][self.cur_pos[1]]
    end

    def valid_pos?
      @@maze.within_range?(self.cur_pos) &&
        (self.cur_val != "X") &&
        (self.pos_history.index(self.cur_pos) == nil)
    end

    class << self
      def find_route(maze, start: "s", goal: "g")
        @@maze = maze
        @@path = [start] + (maze.maze_map.flatten - ["."] - ["X"] - [start] - [goal]).sort
        @@goal = goal

        self.new_from_val(start).to_goal
      end

      def new_from_val(p)
        self.new(@@maze.pos(p))
      end
    end
  end
end

map_str = gets.gsub("\n", "")
maze = Maze::Maze.new(map_str)
result = Maze::Route.find_route(maze)
puts( result ? result.pos_history.count : "-")

# [
#   "....../.s..../..2.../...1../....g."
#   # ".s..g./....../XXXXXX/....../.1..2.",
#   # "3..5../.X4.X./.2g9.6/....7X/s18..."
# ].each do |example|
#   maze = Maze::Maze.new(example)
#   result = Maze::Route.find_route(maze)
#   p result&.pos_history&.count
#   p result&.pos_history
#   p "----------------"
# end
