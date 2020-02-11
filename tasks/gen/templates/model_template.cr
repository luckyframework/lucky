class Lucky::ModelTemplate < Teeplate::FileTree
  @name : String
  @columns : Array(Lucky::GeneratedColumn)
  @pluralized_name : String
  @underscored_name : String

  getter underscored_name

  directory "#{__DIR__}/model/"

  def initialize(@name : String, @columns : Array(Lucky::GeneratedColumn))
    @underscored_name = @name.underscore
    @pluralized_name = Wordsmith::Inflector.pluralize(@underscored_name)
  end
end
