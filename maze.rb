class Maze
  MAP_RANGE = [0..5, 0..4]

  attr_reader :maze_map

  def initialize(str)
    @maze_map = str.split("/").map{|m| m.split("")}.transpose
  end

  def within_range(pos)
    MAP_RANGE[0].include?(pos[0]) && MAP_RANGE[1].include?(pos[1])
  end

  def path
    @maze_map.flatten.uniq.reject{|m| m =~ /\.|X|s/}.sort
  end

  def pos(str)
    @maze_map.flatten.index(str).divmod(@maze_map.count-1)
  end
end

class Route
  NEXT_POS = [[-1, 0], [1, 0], [0, -1], [0,1]]
  LOOP_LIMIT = 10000

  attr_reader :cur_pos, :maze, :history

  def initialize(pos, previous=nil)
    @cur_pos = pos
    @history = previous&.history&.dup&.push(previous&.cur_pos) || []
  end

  def to_goal
    current = self
    @@maze.path.each do |p|
      current = current.step_to(p)
      break unless current
      p current.history
      p current.cur_pos
    end
    return current
  end

  def step_to(str)
    nexts = [self]
    (0..LOOP_LIMIT).each do
      nexts = nexts.map{|n| n.next}.flatten
      return nil if nexts.empty?
      nexts.each do |n|
        return n if n.cur_val == str
      end
    end
    raise "Loop limit !"
  end

  protected

  def next
    @next ||= NEXT_POS.map{|p|
      pos = [self.cur_pos, p].transpose.map{|a| a.inject(:+)}
      self.class.new(pos, self)
    }.select{|n| n.valid_pos?}
  end

  def cur_val
    @@maze.maze_map.dig(*self.cur_pos)
  end

  def valid_pos?
    @@maze.within_range(self.cur_pos) &&
      (self.cur_val != "X") &&
      (self.history.index(self.cur_pos) == nil)
  end

  class << self
    def new_pos(p)
      self.new(@@maze.pos(p))
    end

    def maze=(m)
      @@maze = m
    end
  end
end


[
  "....../.s..../..2.../...1../....g.",
  # ".s..g./....../XXXXXX/....../.1..2.",
  "3..5../.X4.X./.2g9.6/....7X/s18..."
].each do |example|
  Route.maze = Maze.new(example)
  result = Route.new_pos("s").to_goal
  p result&.history&.count
  p result&.history
  p "----------------"
end
