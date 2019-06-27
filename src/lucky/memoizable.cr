module Lucky::Memoizable
  # Creates an instance variable to store the return value of the method.
  #
  # This allows you to create a method with an expensive or long running task
  # that may be called multiple times without re-evaluating the method on each call.
  #
  # To define a memoized method, you'll use this `memoize` macro like this:
  # ```
  # class BrowserAction
  #   memoize def calculate_data : ReportData
  #     # some heavy task to return data
  #   end
  # end
  # ```
  #
  # Now you can use the `calculate_data` method, and it will only run the heavy task
  # the first time you call it. Each subsequent call returns the calculated value.
  #
  # The `memoize` method will raise a compile time exception if you forget to include
  # a return type for your method, or if your return type is a `Union`.
  macro memoize(method_def)
    {% raise "Return type of memoize method must not be a Union" if method_def.return_type.is_a?(Union) %}
    {% raise "You must define a return type for memoize methods" if method_def.return_type.is_a?(Nop) %}
    {% raise "Memoize methods can not be defined with arguments" if method_def.args.size > 0 %}

    @__{{ method_def.name }} : {{ method_def.return_type }}? = nil

    # no cache
    def _{{ method_def.name }} : {{ method_def.return_type }}
      {{ method_def.body }}
    end

    # cache
    def {{ method_def.name }} : {{ method_def.return_type }}
      @__{{ method_def.name }} ||= -> do
        _{{ method_def.name }}
      end.call.not_nil!
    end
  end
end
