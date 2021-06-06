module Lucky
  annotation ParamField
  end

  module ParamSerializable
    macro included
      @[Lucky::ParamField(ignore: true)]
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
      {% begin %}
        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Lucky::ParamField) %}
          {% ignore_var = ann && ann[:ignore] %}
          {% unless ignore_var %}
            {% is_nilable_type = ivar.type.nilable? %}
            {% base_type = is_nilable_type ? ivar.type.union_types.reject(&.==(Nil)).first : ivar.type %}
            {% is_array = base_type.name.starts_with?("Array") %}
            {% type = is_array ? base_type.type_vars.first : base_type %}
            {% is_file = type.name.starts_with?("Lucky::UploadedFile") %}

            param_key_value = {{ ann && ann[:param_key] ? ann[:param_key].id.stringify : nil }} || param_key

            {% if is_array %}
            val = if param_key_value
              data = params.nested_array?(param_key_value)
              data.get(:{{ ivar.id }})
            else
              params.get_all?(:{{ ivar.id }})
            end
            {% else %}
            val = if param_key_value
              data = params.nested{% if is_file %}_file{% end %}?(param_key_value.not_nil!)
              data.get(:{{ ivar.id }})
            else
              params.get{% if is_file %}_file{% end %}?(:{{ ivar.id }})
            end
            {% end %}

            if val.nil?
              default_or_nil = {{ ivar.has_default_value? ? ivar.default_value : nil }}
              {% if is_nilable_type %}
              @{{ ivar.id }} = default_or_nil
              {% else %}
              if default_or_nil.nil?
                raise Lucky::MissingParamError.new <<-ERROR
                {{ @type }} is missing value for required param "{{ ivar.id }} : {{ ivar.type }}"
                ERROR
              else
                @{{ ivar.id }} = default_or_nil
              end
              {% end %}
            else
              # NOTE: these come from Avram directly
              result = {{ type }}::Lucky.parse(val)

              if result.is_a? Avram::Type::SuccessfulCast
                @{{ ivar.id }} = result.value.as({{ base_type }})
              else
                raise Lucky::InvalidParamError.new(
                  param_name: "{{ ivar.id }}",
                  param_value: val.to_s,
                  param_type: "{{ type }}"
                )
              end
            end
          {% end %}
        {% end %}
      {% end %}
    end
  end
end
