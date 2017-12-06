class Lucky::QueryTemplate < Teeplate::FileTree
  directory "#{__DIR__}/query"

  def initialize(@name : String)
  end
end

