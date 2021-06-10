module Lucky
  annotation ParamField
  end

  module ParamSerializable
    macro included
      @[Lucky::ParamField(ignore: true)]
      @_original_source : Lucky::Params?

      @[Lucky::ParamField(ignore: true)]
      @_param_key : String?

      @[Lucky::ParamField(ignore: true)]
      getter metadata : Hash(String, Hash(String, String?)) do
        {} of String => Hash(String, String?)
      end

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

    def has_source?(key : String) : Bool
      metadata[key]["received_data"]? == "true"
    end

    def original_source : Lucky::Params
      @_original_source.not_nil!
    end

    def initialize(*, __param_data params : Lucky::Params)
      @_original_source = params
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
            {% is_param_serializable = type.resolve < Lucky::ParamSerializable %}

            param_key_value = {{ ann && ann[:param_key] ? ann[:param_key].id.stringify : nil }} || param_key

            metadata[{{ ivar.id.stringify }}] = {} of String => String?
            metadata[{{ ivar.id.stringify }}]["param_key"] = param_key_value

            {% if is_array %}
            val = if param_key_value
              data = params.nested_array{% if is_file %}_files{% end %}?(param_key_value)
              metadata[{{ ivar.id.stringify }}]["received_data"] = data.has_key?({{ ivar.id.stringify }}).to_s
              data.get(:{{ ivar.id }})
            else
              metadata[{{ ivar.id.stringify }}]["received_data"] = params.has_key?("{{ ivar.id }}[]").to_s
              params.get_all{% if is_file %}_files{% end %}?(:{{ ivar.id }})
            end
            {% else %}
            val = if param_key_value
              data = params.nested{% if is_file %}_file{% end %}?(param_key_value.not_nil!)

              {% if is_param_serializable %}
              metadata[{{ ivar.id.stringify }}]["received_data"] = data.keys.any?(&.starts_with?({{ ivar.id.stringify }})).to_s
              Lucky::Params.from_hash(data)
              {% else %}
              metadata[{{ ivar.id.stringify }}]["received_data"] = data.has_key?({{ ivar.id.stringify }}).to_s
              data.get(:{{ ivar.id }})
              {% end %}
            else
              metadata[{{ ivar.id.stringify }}]["received_data"] = params.has_key?("{{ ivar.id }}").to_s
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
              {% if is_param_serializable %}
              @{{ ivar.id }} = {{ type }}.from_params(val.as(Lucky::Params))
              {% else %}
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
              {% end %}
            end
          {% end %}
        {% end %}
      {% end %}
    end
  end
end
