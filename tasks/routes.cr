require "lucky_cli"
require "colorize"
require "shell-table"

class Routes < LuckyCli::Task
  summary "Show all the routes for the app"

  def call
    routes = Lucky::Router.routes.map do |route|
      [route.method.to_s.upcase, route.path.colorize(:green), route.action]
    end

    table = ShellTable.new(
      labels: ["Verb", "URI", "Action"],
      label_color: :blue,
      rows: routes
    )

    puts table
  end
end
