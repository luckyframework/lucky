require "lucky_cli"
require "teeplate"
require "avram"
require "./templates/model_template"
require "wordsmith"

class Gen::Model < LuckyCli::Task
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

  def create_migration
    Avram::Migrator::MigrationGenerator.new(
      "Create#{pluralized_model_name}",
      migrate_contents: migrate_contents,
      rollback_contents: rollback_contents
    ).generate
  end

  private def migrate_contents
    String.build do |string|
      string << "create table_for(#{model_name}) do\n"
      string << "  primary_key id : Int64\n"
      string << "  add_timestamps\n"
      string << "end"
    end
  end

  private def rollback_contents : String
    "drop table_for(#{model_name})"
  end

  private def pluralized_model_name
    Wordsmith::Inflector.pluralize(model_name)
  end

  private def valid?
    model_name_is_present && model_name_is_camelcase && model_name_matches_format
  end

  private def model_name_is_present
    @error = "Model name is required. Example: lucky gen.model User"
    ARGV.first?
  end

  private def model_name_is_camelcase
    @error = "Model name should be camel case. Example: lucky gen.model #{model_name.camelcase}"
    model_name.camelcase == model_name
  end

  private def model_name_matches_format
    formatted = model_name.gsub(/[^\w]/, "")
    @error = "Model name should only contain letters. Example: lucky gen.model #{formatted}"
    model_name == formatted
  end

  private def template
    Lucky::ModelTemplate.new(model_name)
  end

  private def display_success_messages
    io.puts success_message("./src/models/#{underscored_name}.cr")
    io.puts success_message("./src/operations/save_#{underscored_name}.cr", "Operation")
    io.puts success_message("./src/queries/#{underscored_name}_query.cr", "Query")
  end

  private def success_message(filename, type = nil)
    "Generated #{model_name.colorize(:green)}#{type.colorize(:green)} in #{filename.colorize(:green)}"
  end

  private def model_name
    ARGV.first
  end

  private def underscored_name
    template.underscored_name
  end
end
