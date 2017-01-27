class LuckyWeb::Router
  INSTANCE = new

  getter :routes

  def initialize
    @tree = Radix::Tree(LuckyWeb::Action.class).new
    @routes = [] of {method: Symbol, path: String, action: LuckyWeb::Action.class}
  end

  def self.add(path, action)
    INSTANCE.add(path, action)
  end

  def self.routes
    INSTANCE.routes
  end

  def add(path, action)
    @tree.add(path, action)
    @routes << {method: :get, path: path, action: action}
  end

  def find_action(path)
    @tree.find(path)
  end

  def self.find_action(path)
    INSTANCE.find_action(path)
  end
end
