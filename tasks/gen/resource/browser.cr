require "lucky_cli"
require "teeplate"
require "lucky_inflector"
require "lucky_record"

class Gen::Resource::Browser < LuckyCli::Task
  banner "Generate a resource (model, form, query, actions, and pages)"
  getter io : IO = STDOUT

  class InvalidOption < Exception
    def initialize(message : String)
      super message
    end
  end

  def call(@io : IO = STDOUT)
    validate!
    generate_resource
    io.puts "\nRun generated migrations with #{"lucky db.migrate".colorize.green}"
    display_path_to_resource
  rescue e : InvalidOption
    io.puts e.message.colorize.red
  end

  private def columns : Array(Lucky::GeneratedColumn)
    column_definitions.map do |column_definition|
      column_name, column_type = column_definition.split(":")
      Lucky::GeneratedColumn.new(name: column_name, type: column_type)
    end
  end

  private def generate_resource
    Lucky::ResourceTemplate.new(resource_name, columns).render("./src/")
    LuckyRecord::Migrator::MigrationGenerator.new(
      "Create" + pluralized_resource,
      migrate_contents: migrate_contents,
      rollback_contents: rollback_contents
    ).generate
    display_success_messages
  end

  private def display_path_to_resource
    io.puts "\nView list of #{pluralized_resource} in your browser at: #{path_to_resource.colorize.green}"
  end

  private def path_to_resource
    "/" + pluralized_resource.underscore
  end

  private def migrate_contents : String
    String.build do |string|
      string << "create :#{pluralized_resource.underscore} do\n"
      columns.each do |column|
        string << "  add #{column.name} : #{column.type}\n"
      end
      string << "end"
    end
  end

  private def rollback_contents : String
    "drop :#{pluralized_resource.underscore}"
  end

  private def validate! : Void
    validate_name_is_present!
    validate_not_namespaced!
    validate_name_is_singular!
    validate_name_is_camelcase!
    validate_has_valid_columns!
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
    singularized_name = LuckyInflector::Inflector.singularize(resource_name)
    if singularized_name != resource_name
      error "Resource must be singular. Example: lucky gen.resource.browser #{singularized_name}"
    end
  end

  private def validate_name_is_camelcase!
    if resource_name.camelcase != resource_name
      error "Resource name should be camel case. Example: lucky gen.resource.browser #{resource_name.camelcase}"
    end
  end

  private def validate_has_valid_columns!
    if !columns_are_valid?
      error "Must provide valid columns for the resource: lucky gen.resource.browser #{resource_name.camelcase} name:String"
    end
  end

  private def error(message : String)
    raise InvalidOption.new(message)
  end

  private def column_definitions
    if column_arguments?
      ARGV.skip(1)
    else
      [] of String
    end
  end

  private def column_arguments? : Bool
    !!ARGV[1]?
  end

  private def columns_are_valid? : Bool
    column_definitions.any? && column_definitions.all? do |column_definition|
      column_parts = column_definition.split(":")
      column_name = column_parts.first
      column_parts.size == 2 && column_name == column_name.underscore
    end
  end

  private def display_success_messages
    success_message(resource_name, "./src/models/#{underscored_resource}.cr")
    success_message(resource_name + "Form", "./src/forms/#{underscored_resource}_form.cr")
    success_message(resource_name + "Query", "./src/queries/#{underscored_resource}_query.cr")
    %w(index show new create edit update delete).each do |action|
      success_message(
        pluralized_resource + "::" + action.capitalize,
        "./src/actions/#{folder_name}/#{action}.cr"
      )
    end
    %w(index show new edit).each do |action|
      success_message(
        pluralized_resource + "::" + action.capitalize + "Page",
        "./src/pages/#{folder_name}/#{action}_page.cr"
      )
    end
  end

  private def underscored_resource
    resource_name.underscore
  end

  private def folder_name
    LuckyInflector::Inflector.pluralize underscored_resource
  end

  private def pluralized_resource
    LuckyInflector::Inflector.pluralize resource_name
  end

  private def success_message(class_name : String, filename : String) : Void
    io.puts "Generated #{class_name.colorize.green} in #{filename.colorize.green}"
  end

  private def resource_name
    resource_name?.not_nil!
  end

  private def resource_name?
    ARGV.first?
  end
end

class Lucky::GeneratedColumn
  getter name, type

  def initialize(@name : String, @type : String)
  end
end

class Lucky::ResourceTemplate < Teeplate::FileTree
  directory "#{__DIR__}/../templates/resource"

  getter resource, columns
  getter form_filename : String,
    query_filename : String,
    underscored_resource : String,
    folder_name : String

  def initialize(@resource : String, @columns : Array(Lucky::GeneratedColumn))
    @form_filename = form_class.underscore
    @query_filename = query_class.underscore
    @underscored_resource = @resource.underscore
    @folder_name = pluralized_resource.underscore
  end

  private def pluralized_resource
    LuckyInflector::Inflector.pluralize(resource)
  end

  private def query_class
    "#{resource}Query"
  end

  private def form_class
    "#{resource}Form"
  end
end
