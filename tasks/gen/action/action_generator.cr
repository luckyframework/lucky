require "ecr"
require "colorize"
require "lucky_template"
require "../../../src/lucky/route_inferrer"

class Lucky::ActionTemplate
  @name : String
  @action : String
  @inherit_from : String
  @route : String
  @save_path : String

  def initialize(@name, @action, @inherit_from, @route)
    @save_path = @name.split("::").map(&.underscore.downcase)[0..-2].join('/')
  end

  def render(path : Path)
    LuckyTemplate.write!(path, template_folder)
  end

  def template_folder
    LuckyTemplate.create_folder do |root_dir|
      root_dir.add_folder(Path["src/actions/#{@save_path}"]) do |actions_dir|
        actions_dir.add_file("#{@action}.cr") do |io|
          ECR.embed("#{__DIR__}/../templates/action/action.cr.ecr", io)
        end
      end
    end
  end
end

module Gen::ActionGenerator
  private def render_action_template(io, inherit_from : String)
    if valid?
      Lucky::ActionTemplate.new(action_name, action, inherit_from, route).render(Path["."])
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
    action_name.presence
  end

  private def name_matches_format
    @error = "That's not a valid Action. Example: lucky gen.action Users::Index"
    action_name.includes?("::")
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

  private def action
    path_args.last
  end

  private def output_path
    Path["./src/actions/#{path}"].normalize
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
