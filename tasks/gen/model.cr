class Gen::Model < LuckyCli::Task
  banner "Generate a model, query, and form"
  getter io : IO = STDOUT

  def call(@io : IO = STDOUT)
    if ARGV.first?
      template.render("./src/")
      display_success_messages
    else
      io.puts "Model name is required. Example: lucky gen.model User".colorize(:red)
    end
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
    "Generated #{model_name.colorize(:green)}#{type} in #{filename.colorize(:green)}"
  end

  private def model_name
    ARGV.first
  end

  private def underscored_name
    template.underscored_name
  end
end
