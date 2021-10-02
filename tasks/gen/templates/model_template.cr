class Lucky::ModelTemplate < Teeplate::FileTree
  @name : String
  @namespace : String
  @columns : Array(Lucky::GeneratedColumn)
  @underscored_name : String
  @underscored_namespace_path : String

  getter underscored_name
  getter underscored_namespace_path

  directory "#{__DIR__}/model/"

  def initialize(full_name : String, @columns : Array(Lucky::GeneratedColumn))
    @namespace, _, @name = full_name.partition(/\b(?=\w+$)/)
    @underscored_name = @name.underscore
    @underscored_namespace_path = @namespace.underscore.gsub("::", "/")
  end

  def columns_list
    (!@columns.empty? ? @columns : example_columns).map(&.name).join(", ")
  end

  private def example_columns
    [
      Lucky::GeneratedColumn.new("column_1", ""),
      Lucky::GeneratedColumn.new("column_2", ""),
    ]
  end
end
