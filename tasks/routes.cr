require "lucky_cli"
require "colorize"

class Routes < LuckyCli::Task
  summary "Show all the routes for the app"

  def call
    table = String.build do |output|
      Lucky::Router.routes.map do |route|
        output << "#{route.method.to_s.upcase} #{route.path.colorize.green}\n"
        output << "  Action       ▸ #{route.action}\n"
        if has_query_params?(route.action)
          output << "  Query params ▸ #{query_param_display(route.action)}\n"
        end
        output << "  Route helper ▸ #{route_helper_display(route.action)}\n"
        output << "\n\n"
      end
    end

    puts table
  end

  private def has_query_params?(action : Lucky::Action.class) : Bool
    action.query_param_declarations.any?
  end

  private def param_declaration(declaration : String) : Array(String)
    declaration.split(" : ")
  end

  private def query_param_display(action : Lucky::Action.class) : String
    action.query_param_declarations.map { |declaration|
      name, type = param_declaration(declaration)
      "#{name} : #{type.colorize.yellow}"
    }.join(", ")
  end

  private def route_helper_display(action : Lucky::Action.class) : String
    if has_query_params?(action)
      first_param = action.query_param_declarations.first
      name, type = param_declaration(first_param)
      %{#{action}.with(#{name}: "#{example_param_by_type(type)}")}
    else
      "#{action}.route"
    end
  end

  private def example_param_by_type(type : String) : String
    case type
    when .includes?("Int")
      "4"
    when .includes?("Bool")
      "false"
    else
      "example"
    end
  end
end
