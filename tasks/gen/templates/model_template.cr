class Lucky::ModelTemplate < Teeplate::FileTree
  @name : String
  @pluralized_name : String
  @underscored_name : String

  getter underscored_name

  directory "#{__DIR__}/model/"

  def initialize(@name : String)
    @pluralized_name  = LuckyInflector::Inflector.pluralize(@name)
    @underscored_name = @name.underscore
  end
end
