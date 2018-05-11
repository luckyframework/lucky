require "lucky_cli"
require "teeplate"
require "./templates/model_template"
require "lucky_inflector"

class Gen::Model < LuckyCli::Task
  banner "Generate a model, query, and form"
  getter io : IO = STDOUT

  def call(@io : IO = STDOUT)
    if valid?
      template.render("./src/")
      create_migration(Gen::Migration)
      display_success_messages
    else
      io.puts @error.colorize(:red)
    end
  end

  macro create_migration(migration_task)
    {% if migration_task.resolve? %}
      Gen::Migration.new.call(name: "CreateContactInfo")
    {% end %}
  end

  private def valid?
    model_name_is_present && model_name_is_camelcase
  end

  private def model_name_is_present
    @error = "Model name is required. Example: lucky gen.model User"
    ARGV.first?
  end

  private def model_name_is_camelcase
    @error = "Model name should be camel case. Example: lucky gen.model #{model_name.camelcase}"
    model_name.camelcase == model_name
  end

  private def template
    Lucky::ModelTemplate.new(model_name)
  end

  private def display_success_messages
    io.puts success_message("./src/models/#{underscored_name}.cr")
    io.puts success_message("./src/forms/#{underscored_name}_form.cr", "Form")
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
