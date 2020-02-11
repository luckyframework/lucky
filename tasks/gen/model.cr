require "lucky_cli"
require "teeplate"
require "avram"
require "./templates/model_template"
require "wordsmith"
require "./mixins/migration_with_columns"

class Gen::Model < LuckyCli::Task
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

      lucky gen.model Project title:String completed:Bool priority:Int32
    TEXT
  end

  def create_migration
    Avram::Migrator::MigrationGenerator.new(
      "Create#{pluralized_subject_name}",
      migrate_contents: migrate_contents,
      rollback_contents: rollback_contents
    ).generate
  end

  private def pluralized_subject_name
    Wordsmith::Inflector.pluralize(subject_name)
  end

  private def valid?
    subject_name_is_present &&
      subject_name_is_camelcase &&
      subject_name_matches_format &&
      columns_are_supported
  end

  private def subject_name_is_present
    @error = "Model name is required. Example: lucky gen.model User"
    ARGV.first?
  end

  private def subject_name_is_camelcase
    @error = "Model name should be camel case. Example: lucky gen.model #{subject_name.camelcase}"
    subject_name.camelcase == subject_name
  end

  private def subject_name_matches_format
    formatted = subject_name.gsub(/[^\w]/, "")
    @error = "Model name should only contain letters. Example: lucky gen.model #{formatted}"
    subject_name == formatted
  end

  private def columns_are_supported
    @error = unsupported_columns_error("model")
    columns_are_valid?
  end

  private def template
    Lucky::ModelTemplate.new(subject_name)
  end

  private def display_success_messages
    io.puts success_message("./src/models/#{underscored_name}.cr")
    io.puts success_message("./src/operations/save_#{underscored_name}.cr", "Operation")
    io.puts success_message("./src/queries/#{underscored_name}_query.cr", "Query")
  end

  private def success_message(filename, type = nil)
    "Generated #{subject_name.colorize(:green)}#{type.colorize(:green)} in #{filename.colorize(:green)}"
  end

  private def subject_name
    ARGV.first
  end

  private def underscored_name
    template.underscored_name
  end
end
