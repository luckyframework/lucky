module Lucky::Memoizable
  # Caches the return value of the method. Helpful for expensive methods that are called more than once.
  #
  # To memoize a method, prefix it with `memoize`:
  #
  # ```
  # class BrowserAction
  #   memoize def current_user : User
  #     # Get the current user
  #   end
  # end
  # ```
  #
  # This will fetch the user record on the first `current_user` call,
  # then each subsequent call returns the user record.
  #
  # The `memoize` method will raise a compile time exception if you forget to include
  # a return type for your method, or if any arguments are missing a type.
  # The result of a set of arguments is only kept until the passed arguments change.
  # Once they change, passing previous arguments will re-run the memoized method.
  # Equality (==) is used for checking on argument updates.
  macro memoize(method_def)
    {% raise "You must define a return type for memoized methods" if method_def.return_type.is_a?(Nop) %}
    {%
      raise "All arguments must have an explicit type restriction for memoized methods" if method_def.args.any? &.restriction.is_a?(Nop)
    %}

    {%
      special_ending = nil
      safe_method_name = method_def.name
    %}

    {%
      if method_def.name.ends_with?('?')
        special_ending = "?"
        safe_method_name = method_def.name.tr("?", "")
      elsif method_def.name.ends_with?('!')
        special_ending = "!"
        safe_method_name = method_def.name.tr("!", "")
      end
    %}

    @__memoized_{{safe_method_name}} : Tuple(
      {{ method_def.return_type }},
      {% for arg in method_def.args %}
        {{ arg.restriction }},
      {% end %}
    )?

    # Returns uncached value
    def {{ safe_method_name }}__uncached{% if special_ending %}{{ special_ending.id }}{% end %}(
      {% for arg in method_def.args %}
        {{ arg.name }} : {{ arg.restriction }},
      {% end %}
    ) : {{ method_def.return_type }}
      {{ method_def.body }}
    end

    # Checks the passed arguments against the memoized args
    # and runs the method body if it is the very first call
    # or the arguments do not match
    def {{ safe_method_name }}__tuple_cached{% if special_ending %}{{ special_ending.id }}{% end %}(
      {% for arg in method_def.args %}
        {{ arg.name }} : {{ arg.restriction }},
      {% end %}
    ) : Tuple(
      {{ method_def.return_type }},
      {% for arg in method_def.args %}
        {{ arg.restriction }},
      {% end %}
    )
      {% for arg, index in method_def.args %}
        @__memoized_{{ safe_method_name }} = nil if {{arg.name}} != @__memoized_{{ safe_method_name }}.try &.at({{index}} + 1)
      {% end %}
      @__memoized_{{ safe_method_name }} ||= -> do
        result = {{ safe_method_name }}__uncached{% if special_ending %}{{ special_ending.id }}{% end %}(
          {% for arg in method_def.args %}
            {{arg.name}},
          {% end %}
        )
        {
          result,
          {% for arg in method_def.args %}
            {{arg.name}},
          {% end %}
        }
      end.call.not_nil!
    end

    # Returns cached value
    def {{ method_def.name }}(
      {% for arg in method_def.args %}
        {% has_default = arg.default_value || arg.default_value == false || arg.default_value == nil %}
        {{ arg.name }} : {{ arg.restriction }}{% if has_default %} = {{ arg.default_value }}{% end %},
      {% end %}
    ) : {{ method_def.return_type }}
      {{ safe_method_name }}__tuple_cached{% if special_ending %}{{ special_ending.id }}{% end %}(
        {% for arg in method_def.args %}
          {{arg.name}},
        {% end %}
      ).first
    end
  end
end
