require "lucky_task"
require "colorize"
require "shell-table"
require "json"

class Routes < LuckyTask::Task
  summary "Show all the routes for the app"
  help_message <<-TEXT
  #{task_summary}

  Optionally, you can pass the --with-params flag (-p) to print out
  the available params for each Action.

  example: lucky routes --with-params

  You can also output routes as JSON using the --format flag (-f).

  example: lucky routes --format=json

  Routing documentation:

      https://luckyframework.org/guides/http-and-routing/routing-and-params
  TEXT

  switch :with_params, "Include action params with each route", shortcut: "-p"
  arg :format, "Output format (table or json)", shortcut: "-f", optional: true

  def call
    routes = Lucky.router.list_routes

    formatted = case format
                when "json"
                  build_json_from_routes(routes)
                else
                  build_table_from_routes(routes)
                end

    output.puts formatted
  end

  private def build_table_from_routes(routes : Array(Tuple(String, String, Lucky::Action.class))) : String
    rows = [] of Array(String)

    routes.each do |path, method, action|
      # skip HEAD routes
      # LuckyRouter creates these routes from any GET routes submitted
      # This could be an issue if users define their own HEAD routes
      next if method.upcase == "HEAD"

      row = [] of String
      row << method.upcase
      row << path.colorize.green.to_s
      row << action.name
      rows << row

      if with_params?
        action.query_param_declarations.each do |param|
          param_row = [] of String
          param_row << " "
          param_row << " #{dim_arrow} #{param}"
          param_row << " "
          rows << param_row
        end
      end
    end

    table = ShellTable.new(
      labels: ["Verb", "URI", "Action"],
      label_color: :white,
      rows: rows
    )

    <<-TEXT
    #{print_banner_message}

    #{table}
    TEXT
  end

  private def build_json_from_routes(routes : Array(Tuple(String, String, Lucky::Action.class))) : String
    info = [] of RouteInfo
    routes.each do |path, method, action|
      next if method.upcase == "HEAD"

      params = if with_params?
                 action.query_param_declarations.map do |param|
                   # param format is "name : Type" - split and trim
                   parts = param.split(" : ", 2)
                   ParamInfo.new(name: parts[0], type: parts[1]? || "String")
                 end
               else
                 [] of ParamInfo
               end

      info << RouteInfo.new(
        method: method.upcase,
        path: path,
        action: action.name,
        params: params
      )
    end

    info.to_pretty_json
  end

  private record ParamInfo, name : String, type : String do
    include JSON::Serializable
  end

  private record RouteInfo, method : String, path : String, action : String, params : Array(ParamInfo) do
    include JSON::Serializable
  end

  private def dim_arrow : Colorize::Object(String)
    "▸".colorize.dim
  end

  private def print_banner_message : Colorize::Object(String)
    <<-TEXT.colorize.dim

    Routing documentation:

      https://luckyframework.org/guides/http-and-routing/routing-and-params
    TEXT
  end
end
