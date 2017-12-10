class Gen::Model < LuckyCli::Task
  banner "Generate a model, query, and form"
  getter io : IO = STDOUT

  def call(@io : IO = STDOUT)
    if ARGV.first?
      Lucky::ModelTemplate.new(model_name).render("./src/")
      display_success_messages
    else
      io.puts "Model name is required. Example: lucky gen.model User".colorize(:red)
    end
  end

  private def display_success_messages
    io.puts success_message("#{underscored_name}.cr", "./src/models/")
    io.puts success_message("#{underscored_name}_form.cr", "./src/forms/")
    io.puts success_message("#{underscored_name}_query.cr", "./src/queries/")
  end

  private def model_name
    ARGV.first
  end

  private def underscored_name
    model_name.underscore
  end

  private def success_message(file, output_path)
    "Done generating #{file.colorize(:green)} in #{output_path.colorize(:green)}"
  end
end
