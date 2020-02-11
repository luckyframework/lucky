module Gen::Mixins::MigrationWithColumns
  SUPPORTED_TYPES = {"Bool", "Float64", "Int16", "Int32", "Int64", "String", "Time", "UUID"}

  private def migrate_contents : String
    String.build do |string|
      string << "# Learn about migrations at: https://luckyframework.org/guides/database/migrations"
      string << "\n"
      string << "create table_for(#{resource_name}) do\n"
      string << "  primary_key id : Int64\n"
      string << "  add_timestamps\n"
      columns.each do |column|
        string << "  add #{column.name} : #{column.type}\n"
      end
      string << "end"
    end
  end

  private def rollback_contents : String
    "drop table_for(#{resource_name})"
  end

  private def columns : Array(Lucky::GeneratedColumn)
    column_definitions.map do |column_definition|
      column_name, column_type = parse_definition(column_definition)
      Lucky::GeneratedColumn.new(name: column_name, type: column_type)
    end
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

  private def columns_are_valid?(required : Bool = false) : Bool
    (!required || column_definitions.any?) && column_definitions.all? do |column_definition|
      column_parts = parse_definition(column_definition)
      column_name = column_parts.first
      column_type = column_parts.last
      column_parts.size == 2 &&
        column_name == column_name.underscore &&
        SUPPORTED_TYPES.includes?(column_type)
    end
  end

  private def parse_definition(column_definition : String) : Array(String)
    column_definition.split(':', 2)
  end

  private def unsupported_columns_error(subject : String, generator : String = subject)
    <<-ERR
    Must provide a supported column type for the #{subject}: lucky gen.#{generator || subject} #{resource_name.camelcase} name:String

    Other complex types can be added manually. See https://luckyframework.org/guides/database/migrations#add-column for more details.
    ERR
  end
end

class Lucky::GeneratedColumn
  getter name, type

  def initialize(@name : String, @type : String)
  end
end
