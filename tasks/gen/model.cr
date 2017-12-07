class Gen::Model < LuckyCli::Task
  banner "Generate a model, query, and form"
  getter io : IO = STDOUT

  def call(@io : IO = STDOUT)
    if ARGV.first?
      render_templates
    else
      io.puts "Model name is required. Example: lucky gen.model User".colorize(:red)
    end
  end

  private def render_templates
    Lucky::ModelTemplate.new(model_name).render("./src/models/")
    io.puts success_message("#{model_name}.cr", "./src/models/")
    Lucky::FormTemplate.new(model_name).render("./src/forms/")
    io.puts success_message("#{model_name}_form.cr", "./src/forms/")
    Lucky::QueryTemplate.new(model_name).render("./src/queries/")
    io.puts success_message("#{model_name}_query.cr", "./src/queries/")
  end

  private def model_name
    ARGV.first.downcase
  end

  private def success_message(file, output_path)
    "Done generating #{file.colorize(:green)} in #{output_path.colorize(:green)}"
  end
end
