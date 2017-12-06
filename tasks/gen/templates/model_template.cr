class Lucky::ModelTemplate < Teeplate::FileTree
  @name : String
  @pluralized_name : String

  directory "#{__DIR__}/model"

  def initialize(@name : String)
    @pluralized_name  = LuckyInflector::Inflector.pluralize(@name)
  end
end
