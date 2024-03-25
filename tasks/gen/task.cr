require "lucky_task"
require "lucky_template"
require "colorize"

class Lucky::TaskTemplate
  def initialize(
    @task_filename : String,
    @task_name : String,
    @summary : String
  )
  end

  def render(path : Path)
    LuckyTemplate.write!(path, template_folder)
  end

  def template_folder
    LuckyTemplate.create_folder do |root_dir|
      root_dir.add_file(Path["tasks/#{@task_filename}.cr"]) do |io|
        ECR.embed("#{__DIR__}/templates/task/task.cr.ecr", io)
      end
    end
  end
end

class Gen::Task < LuckyTask::Task
  summary "Generate a lucky command line task"
  help_message <<-TEXT
  #{task_summary}

  Example:
    lucky gen.task email.monthly_update

  See Also: https://luckyframework.org/guides/command-line-tasks/custom-tasks
  TEXT

  arg :task_summary, "The -h help text for the task", optional: true
  positional_arg :task_name, "The name of the task to generate"

  def call
    errors = error_messages
    if !errors.empty?
      errors.each do |err|
        output.puts err.colorize.red
      end
    else
      Lucky::TaskTemplate
        .new(task_filename, rendered_task_name, rendered_summary)
        .render(output_path)

      output.puts <<-TEXT
      Generated #{output_path.join(task_filename).colorize.green}

      Run it with:

      lucky #{task_name}
      TEXT
    end
  end

  def error_messages
    messages = [] of String
    messages << "Task name is expected" if task_name.blank?
    unless task_name.underscore == task_name
      messages << "Task name needs to be formatted with dot notation: namespace.task_name"
    end
    messages
  end

  private def relative_path
    Path[task_name.split('.')[0...-1]]
  end

  private def task_filename
    task_name.split('.')[-1] + ".cr"
  end

  private def rendered_task_name
    task_name.split('.').map(&.camelcase).join("::")
  end

  private def rendered_summary
    task_summary || task_name.gsub(/[._]/, ' ')
  end

  private def output_path
    Path[".", "tasks", relative_path]
  end
end
