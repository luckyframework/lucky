class LuckyWeb::Router
  INSTANCE = new

  def initialize
    @tree = Radix::Tree(LuckyWeb::Action.class).new
  end

  def self.add(path, controller)
    INSTANCE.add(path, controller)
  end

  def add(path, controller)
    @tree.add(path, controller)
  end

  def find_action(path)
    @tree.find(path)
  end

  def self.find_action(path)
    INSTANCE.find_action(path)
  end
end
