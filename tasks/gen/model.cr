require "lucky_task"
require "teeplate"
require "avram"
require "./templates/model_template"
require "wordsmith"
require "./mixins/migration_with_columns"

class Gen::Model < LuckyTask::Task
  include Gen::Mixins::MigrationWithColumns

  summary "Generate a model, query, and save operation"
  getter io : IO = STDOUT

  def call(@io : IO = STDOUT)
    if valid?
      template.render("./src/")
      create_migration
      display_success_messages
    else
      io.puts @error.colorize(:red)
    end
  end

  def help_message
    <<-TEXT
    #{summary}

    Example:

      lucky gen.model Project title:String description:String? completed:Bool priority:Int32
    TEXT
  end

  private def valid?
    resource_name_is_present &&
      resource_name_matches_format &&
      resource_name_is_camelcase &&
      columns_are_supported &&
      resource_name_not_taken
  end

  private def resource_name_is_present
    @error = "Model name is required. Example: lucky gen.model User"
    ARGV.first?
  end

  private def resource_name_is_camelcase
    camelcased = resource_name.split("::").map!(&.camelcase).join("::")
    @error = "Model name should be camel case. Example: lucky gen.model #{camelcased}"
    camelcased == resource_name
  end

  private def resource_name_matches_format
    formatted = resource_name.gsub(/[^\w:]/, "")
    @error = "Model name should only contain letters, and possibly a namespace. Example: lucky gen.model #{formatted}"
    resource_name =~ /^([a-z]\w*::)*[a-z]\w*$/i
  end

  private def columns_are_supported
    @error = unsupported_columns_error(resource_name)
    columns_are_valid?
  end

  private def resource_name_not_taken
    @error = "'#{resource_name}' model already exists at #{"./src/models/#{template.underscored_namespace_path}#{template.underscored_name}.cr"}."
    !File.exists?("./src/models/#{template.underscored_namespace_path}#{template.underscored_name}.cr")
  end

  private def template
    Lucky::ModelTemplate.new(resource_name, columns)
  end

  private def display_success_messages
    io.puts success_message("./src/models/#{template.underscored_namespace_path}#{template.underscored_name}.cr")
    io.puts success_message("./src/operations/#{template.underscored_namespace_path}save_#{template.underscored_name}.cr", "Operation")
    io.puts success_message("./src/queries/#{template.underscored_namespace_path}#{template.underscored_name}_query.cr", "Query")
  end

  private def success_message(filename, type = nil)
    "Generated #{resource_name.colorize.green}#{type.colorize.green} in #{filename.colorize.green}"
  end

  private def resource_name
    ARGV.first
  end

  private def pluralized_name
    Wordsmith::Inflector.pluralize(resource_name.gsub("::", ""))
  end
end
