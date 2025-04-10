require "lucky_task"
require "colorize"
require "shell-table"

class Routes < LuckyTask::Task
  summary "Show all the routes for the app"
  help_message <<-TEXT
  #{task_summary}

  Optionally, you can pass the --with-params flag (-p) to print out
  the available params for each Action.

  example: lucky routes --with-params

  Routing documentation:

      https://luckyframework.org/guides/http-and-routing/routing-and-params
  TEXT

  switch :with_params, "Include action params with each route", shortcut: "-p"

  def call
    routes = [] of Array(String)

    Lucky.router.list_routes.each do |path, method, action|
      # skip HEAD routes
      # LuckyRouter creates these routes from any GET routes submitted
      # This could be an issue if users define their own HEAD routes
      next if method.upcase == "HEAD"

      row = [] of String
      row << method.upcase
      row << path.colorize.green.to_s
      row << action.name
      routes << row

      if with_params?
        action.query_param_declarations.each do |param|
          param_row = [] of String
          param_row << " "
          param_row << " #{dim_arrow} #{param}"
          param_row << " "
          routes << param_row
        end
      end
    end

    table = ShellTable.new(
      labels: ["Verb", "URI", "Action"],
      label_color: :white,
      rows: routes
    )

    output.puts <<-TEXT
    #{print_banner_message}

    #{table}
    TEXT
  end

  private def dim_arrow
    "▸".colorize.dim
  end

  private def print_banner_message
    <<-TEXT.colorize.dim

    Routing documentation:

      https://luckyframework.org/guides/http-and-routing/routing-and-params
    TEXT
  end
end
