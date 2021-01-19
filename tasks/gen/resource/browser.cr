require "lucky_cli"
require "teeplate"
require "wordsmith"
require "avram"
require "../mixins/migration_with_columns"
require "../route_inferrer"

class Gen::Resource::Browser < LuckyCli::Task
  include Gen::Mixins::MigrationWithColumns

  summary "Generate a resource (model, operation, query, actions, and pages)"
  getter io : IO = STDOUT

  class InvalidOption < Exception
    def initialize(message : String)
      super message
    end
  end

  def help_message
    <<-TEXT
    #{summary}

    Requires the name of the resource and list of database columns. Columns
    are passed as column_name:ColumnType. Where ColumnType are one of the
    supported Avram datatypes.

    Example:

      lucky gen.resource.browser Project title:String description:String? completed:Bool priority:Int32
    TEXT
  end

  def call(@io : IO = STDOUT)
    validate!
    generate_resource
    io.puts "\nRun generated migrations with #{"lucky db.migrate".colorize.green}"
    display_path_to_resource
  rescue e : InvalidOption
    io.puts e.message.colorize.red
  end

  private def generate_resource
    Lucky::ResourceTemplate.new(resource_name, columns).render("./src/")
    create_migration
    display_success_messages
  end

  private def display_path_to_resource
    io.puts "\nView list of #{pluralized_name} in your browser at: #{path_to_resource.colorize.green}"
  end

  private def path_to_resource
    "/" + pluralized_name.underscore
  end

  private def validate! : Void
    validate_name_is_present!
    validate_not_namespaced!
    validate_name_is_singular!
    validate_name_is_camelcase!
    validate_has_supported_columns!
  end

  private def validate_name_is_present!
    if resource_name?.nil? || resource_name?.try &.empty?
      error "Resource name is required. Example: lucky gen.resource.browser User"
    end
  end

  private def validate_not_namespaced!
    if resource_name.includes?("::")
      error "Namespaced resources are not supported"
    end
  end

  private def validate_name_is_singular!
    singularized_name = Wordsmith::Inflector.singularize(resource_name)
    if singularized_name != resource_name
      error "Resource must be singular. Example: lucky gen.resource.browser #{singularized_name}"
    end
  end

  private def validate_name_is_camelcase!
    if resource_name.camelcase != resource_name
      error "Resource name should be camel case. Example: lucky gen.resource.browser #{resource_name.camelcase}"
    end
  end

  private def validate_has_supported_columns!
    if column_definitions.empty?
      error "Resource requires at least one column definition. Example lucky gen.resource.browser #{resource_name} column_name:String"
    end
    if !columns_are_valid?
      error unsupported_columns_error(resource_name, "resource.browser")
    end
  end

  private def error(message : String)
    raise InvalidOption.new(message)
  end

  private def display_success_messages
    success_message(resource_name, "./src/models/#{underscored_resource}.cr")
    success_message("Save" + resource_name, "./src/operations/save_#{underscored_resource}.cr")
    success_message(resource_name + "Query", "./src/queries/#{underscored_resource}_query.cr")
    %w(index show new create edit update delete).each do |action|
      success_message(
        pluralized_name + "::" + action.capitalize,
        "./src/actions/#{folder_name}/#{action}.cr"
      )
    end
    %w(index show new edit).each do |action|
      success_message(
        pluralized_name + "::" + action.capitalize + "Page",
        "./src/pages/#{folder_name}/#{action}_page.cr"
      )
    end
    success_message("#{pluralized_name}::FormFields", "./src/components/#{folder_name}/form_fields.cr")
  end

  private def underscored_resource
    resource_name.underscore
  end

  private def folder_name
    Wordsmith::Inflector.pluralize underscored_resource
  end

  private def pluralized_name
    Wordsmith::Inflector.pluralize resource_name
  end

  private def success_message(class_name : String, filename : String) : Void
    io.puts "Generated #{class_name.colorize.bold} in #{filename.colorize.bold}"
  end

  private def resource_name
    resource_name?.not_nil!
  end

  private def resource_name?
    ARGV.first?
  end
end

class Lucky::ResourceTemplate < Teeplate::FileTree
  directory "#{__DIR__}/../templates/resource"

  getter resource, columns
  getter operation_filename : String,
    query_filename : String,
    underscored_resource : String,
    folder_name : String

  def initialize(@resource : String, @columns : Array(Lucky::GeneratedColumn))
    @operation_filename = operation_class.underscore
    @query_filename = query_class.underscore
    @underscored_resource = @resource.underscore
    @folder_name = pluralized_name.underscore
  end

  private def pluralized_name
    Wordsmith::Inflector.pluralize(resource)
  end

  private def resource_id_method_name
    "#{underscored_resource}_id"
  end

  private def query_class
    "#{resource}Query"
  end

  private def operation_class
    "Save#{resource}"
  end

  private def route(action)
    Lucky::RouteInferrer.new(action_class_name: "#{pluralized_name}::#{action}").generate_inferred_route
  end
end
