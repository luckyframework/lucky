require "lucky_task"
require "teeplate"
require "colorize"
require "file_utils"

class Lucky::TaskTemplate < Teeplate::FileTree
  directory "#{__DIR__}/templates/task"

  def initialize(
    @task_filename : String,
    @task_name : String,
    @summary : String
  )
  end
end

class Gen::Task < LuckyTask::Task
  summary "Generate a lucky command line task"

  arg :task_summary, "The -h help text for the task", optional: true
  positional_arg :task_name, "The name of the task to generate"

  def call
    errors = error_messages
    if !errors.empty?
      output.puts errors
    else
      Lucky::TaskTemplate
        .new(task_filename, rendered_task_name, rendered_summary)
        .render(output_path.to_s)

      output.puts <<-TEXT
      Generated #{output_path.join task_filename}

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

  def help_message
    <<-TEXT

    #{summary}

    Example:
      lucky gen.task email.monthly_update

    See Also: https://luckyframework.org/guides/command-line-tasks/custom-tasks
    TEXT
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
