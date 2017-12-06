class Lucky::FormTemplate < Teeplate::FileTree
  directory "#{__DIR__}/form"

  def initialize(@name : String)
  end
end

