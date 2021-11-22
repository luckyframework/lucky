require "colorize"
require "file_utils"
require "teeplate"
require "../../../src/lucky/route_inferrer"

class Lucky::ActionTemplate < Teeplate::FileTree
  @name : String
  @action : String
  @inherit_from : String
  @route : String

  directory "#{__DIR__}/../templates/action"

  def initialize(@name, @action, @inherit_from, @route)
  end
end

module Gen::ActionGenerator
  private def render_action_template(io, inherit_from : String)
    if valid?
      Lucky::ActionTemplate.new(action_name, action, inherit_from, route).render(output_path)
      io.puts success_message
    else
      io.puts @error.colorize(:red)
    end
  end

  private def valid?
    name_is_present && name_matches_format && route_generated_from_action_name
  end

  private def name_is_present
    @error = "Action name is required. Example: lucky gen.action Users::Index"
    ARGV.first?
  end

  private def name_matches_format
    @error = "That's not a valid Action. Example: lucky gen.action Users::Index"
    ARGV.first.includes?("::")
  end

  private def route_generated_from_action_name
    route
    true
  rescue ex
    @error = ex.message
    false
  end

  @route : String?

  private def route
    @route ||= Lucky::RouteInferrer.new(action_class_name: action_name).generate_inferred_route
  end

  private def action_name
    ARGV.first
  end

  private def action
    path_args.last
  end

  private def output_path
    "./src/actions/#{path}"
  end

  private def path
    path_args[0..-2].join("/")
  end

  private def path_args
    action_name.split("::").map(&.underscore).map(&.downcase)
  end

  private def success_message
    "Done generating #{action_name.colorize.green} in #{output_path.colorize.green}"
  end
end
