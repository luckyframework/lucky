require "lucky_cli"
require "colorize"

class Routes < LuckyCli::Task
  summary "Show all the routes for the app"

  def call
    table = String.build do |output|
      output << "#{print_banner_message}\n\n"
      Lucky::Router.routes.map do |route|
        output << "#{route.method.to_s.upcase} #{route.path.colorize.bold.underline} #{dim_arrow} #{route.action.colorize.green}\n"
        route.action.query_param_declarations.each do |param|
          output << " #{dim_arrow} #{param}\n"
        end
        output << "\n\n"
      end
    end

    puts table
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
