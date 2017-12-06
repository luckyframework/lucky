class Gen::Model < LuckyCli::Task
  banner "Generate a model, query, and form"

  def call(io : IO = STDOUT)
    if ARGV.first?
      Lucky::ModelTemplate.new(model_name).render("./src/models/")
      Lucky::FormTemplate.new(model_name).render("./src/forms/")
      Lucky::QueryTemplate.new(model_name).render("./src/queries/")
    else
      io.puts "Model name is required. Example: lucky gen.model User".colorize(:red)
    end
  end

  private def model_name
    ARGV.first.downcase
  end
end

