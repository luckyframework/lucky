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
  # a return type for your method, or if your return type is a `Union`.
  # Arguments are not allowed in memoized methods because these can change the return value.
  macro memoize(method_def)
    {% raise "Return type of memoize method must not be a Union" if method_def.return_type.is_a?(Union) %}
    {% raise "You must define a return type for memoize methods" if method_def.return_type.is_a?(Nop) %}
    {% raise "Memoize methods can not be defined with arguments" if method_def.args.size > 0 %}

    @__{{ method_def.name }} : {{ method_def.return_type }}? = nil

    # Returns uncached value
    def {{ method_def.name }}__uncached : {{ method_def.return_type }}
      {{ method_def.body }}
    end

    # Returns cached value
    def {{ method_def.name }} : {{ method_def.return_type }}
      @__{{ method_def.name }} ||= -> do
        {{ method_def.name }}__uncached
      end.call.not_nil!
    end
  end
end
