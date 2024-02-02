module Lucky
  annotation ParamField
  end

  module ParamSerializable
    macro included
      PARAM_DECLARATIONS = [] of Nil

      @_param_key : String?

      def self.from_params(param_data : Lucky::Params)
        new_from_params(param_data)
      end

      private def self.new_from_params(param_data : Lucky::Params)
        instance = allocate
        instance.initialize(__param_data: param_data)
        GC.add_finalizer(instance) if instance.responds_to?(:finalize)
        instance
      end

      macro finished
        generate_needy_initializer
      end
    end

    macro generate_needy_initializer
      {% initializer_args = "" %}
      {% for metadata in @type.constant(:PARAM_DECLARATIONS) %}
        {% initializer_args = initializer_args + "#{metadata[:type_declaration]}" %}
        {% if metadata[:nilable] && !metadata[:type_declaration].value %}
        {% initializer_args = initializer_args + " = nil" %}
        {% end %}
        {% initializer_args = initializer_args + "," %}
      {% end %}

      {% if @type.constant(:PARAM_DECLARATIONS).size > 0 %}
      def initialize(*, {{ initializer_args.id }})
        {% for metadata in @type.constant(:PARAM_DECLARATIONS) %}
          param_key_value = {{ metadata[:param_key] ? metadata[:param_key].id.stringify : nil }} || param_key
          @{{ metadata[:type_declaration].var.id }} = Lucky::PermittedParam({{ metadata[:type_declaration].type }}).new(
            name: {{ metadata[:type_declaration].var.stringify }},
            value: {{ metadata[:type_declaration].var.id }},
            param_key: param_key_value
          )
        {% end %}
      end
      {% end %}
    end

    private def param_key
      @_param_key ||= Wordsmith::Inflector.underscore({{ @type.name.stringify }})
    end

    macro param_key(key)
      private def param_key
        {{ key.id.stringify }}
      end
    end

    macro skip_param_key
      private def param_key
        nil
      end
    end

    def initialize(*, __param_data params : Lucky::Params)
      {% for metadata in @type.constant(:PARAM_DECLARATIONS) %}
        {% begin %}
          %param_key_value = {{ metadata[:param_key] ? metadata[:param_key].id.stringify : nil }} || param_key
          {% if metadata[:is_array] %}
            %val = if %param_key_value
              {% if metadata[:is_file] %}
              %data = params.nested_array_files?(%param_key_value)
              {% else %}
              %data = params.nested_arrays?(%param_key_value)
              {% end %}
              %data.get(:{{ metadata[:type_declaration].var.id }})
            else
              params.get_all{% if metadata[:is_file] %}_files{% end %}?(:{{ metadata[:type_declaration].var.id }})
            end
          {% else %}
            %val = if %param_key_value
              %data = params.nested{% if metadata[:is_file] %}_file{% end %}?(%param_key_value.not_nil!)

              {% if metadata[:is_serializable] %}
              Lucky::Params.from_hash(%data)
              {% else %}
              %data.get(:{{ metadata[:type_declaration].var.id }})
              {% end %}
            else
              params.get{% if metadata[:is_file] %}_file{% end %}?(:{{ metadata[:type_declaration].var.id }})
            end
          {% end %}

          if %val.nil?{% if metadata[:nilable] %} || %val == ""{% end %}
            default_or_nil = {{ metadata[:type_declaration].value ? metadata[:type_declaration].value : nil }}
            {% if metadata[:nilable] %}
              if %val.nil? && default_or_nil.nil?
                @{{ metadata[:type_declaration].var.id }} = nil
              else
                @{{ metadata[:type_declaration].var.id }} = Lucky::PermittedParam({{ metadata[:type_declaration].type }}).new(name: {{ metadata[:type_declaration].var.stringify }}, value: default_or_nil, param_key: %param_key_value)
              end
            {% else %}
              if default_or_nil.nil?
                raise Lucky::MissingParamError.new <<-ERROR
                {{ @type }} is missing value for required param "{{ metadata[:type_declaration] }}"
                ERROR
              else
                @{{ metadata[:type_declaration].var.id }} = Lucky::PermittedParam({{ metadata[:type_declaration].type }}).new(name: {{ metadata[:type_declaration].var.stringify }}, value: default_or_nil, param_key: %param_key_value)
              end
            {% end %}
          else
            {% if metadata[:is_serializable] %}
            @{{ metadata[:type_declaration].var.id }} = Lucky::PermittedParam({{ metadata[:type_declaration].type }}).new(name: {{ metadata[:type_declaration].var.stringify }}, value: {{ metadata[:core_type] }}.from_params(%val.as(Lucky::Params)), param_key: %param_key_value)
            {% else %}
              # NOTE: these come from Avram directly
              %result = {{ metadata[:core_type] }}::Lucky.parse(%val)

              if %result.is_a? Avram::Type::SuccessfulCast
                @{{ metadata[:type_declaration].var.id }} = Lucky::PermittedParam({{ metadata[:type_declaration].type }}).new(name: {{ metadata[:type_declaration].var.stringify }}, value: %result.value.as({{ metadata[:type] }}), param_key: %param_key_value)
              else
                raise Lucky::InvalidParamError.new(
                  param_name: "{{ metadata[:type_declaration].var.id }}",
                  param_value: %val.to_s,
                  param_type: "{{ metadata[:type] }}"
                )
              end
            {% end %}
          end
        {% end %}
      {% end %}
    end

    macro param(type_declaration, param_key = nil)
      {% unless type_declaration.is_a?(TypeDeclaration) %}
        {% raise "'param' expects a type declaration like 'name : String', instead got: '#{type_declaration}'" %}
      {% end %}

      {% is_nilable_type = type_declaration.type.resolve.nilable? %}
      {% type = is_nilable_type ? type_declaration.type.types.reject(&.==(Nil)).first.resolve : type_declaration.type.resolve %}
      {% is_array = type.name.starts_with?("Array") %}
      # TODO: This probably breaks if the type is Array(String?)
      {% core_type = is_array ? type.type_vars.first : type %}
      {% is_file = core_type.name.starts_with?("Lucky::UploadedFile") %}
      {% is_param_serializable = core_type.resolve < Lucky::ParamSerializable %}

      {%
        PARAM_DECLARATIONS << {
          type_declaration: type_declaration,
          param_key:        param_key,
          nilable:          is_nilable_type,
          type:             type,
          core_type:        core_type,
          is_array:         is_array,
          is_file:          is_file,
          is_serializable:  is_param_serializable,
        }
      %}

      getter {{ type_declaration.var }} : Lucky::PermittedParam({{ type_declaration.type }}){% if is_nilable_type %}?{% end %}

      # TODO: This seems to always raise, even though I'm never calling it
      # def {{ type_declaration.var }}=(val : {{ type_declaration.type }})
      #   % raise <<-ERROR
      #   #{@type} values can only be assigned from Lucky::Params, or by initialization.

      #   Try this...

      #     ▸ #{@type}.from_params(params)
      #     ▸ #{@type}.new(#{type_declaration.var}: "my value")
      #   ERROR
      #   %
      # end
    end
  end
end
