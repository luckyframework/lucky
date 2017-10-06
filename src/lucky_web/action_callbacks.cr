module LuckyWeb::ActionCallbacks
  class Continue
  end

  macro included
    AFTER_CALLBACKS = [] of Symbol
    BEFORE_CALLBACKS = [] of Symbol

    macro inherited
      AFTER_CALLBACKS = [] of Symbol
      BEFORE_CALLBACKS = [] of Symbol

      inherit_callbacks
    end
  end

  macro inherit_callbacks
    \{% for v in @type.ancestors.first.constant :BEFORE_CALLBACKS %}
      \{% BEFORE_CALLBACKS << v %}
    \{% end %}

    \{% for v in @type.ancestors.first.constant :AFTER_CALLBACKS %}
      \{% AFTER_CALLBACKS << v %}
    \{% end %}
  end

  macro before(method_name)
    {% BEFORE_CALLBACKS << method_name.id %}
  end

  macro after(method_name)
    {% AFTER_CALLBACKS << method_name.id %}
  end

  macro run_before_callbacks
    {% for callback_method in BEFORE_CALLBACKS %}
      callback_result = {{ callback_method }}
      ensure_callbacks_return_response_or_continue(callback_result)
      if callback_result.is_a?(LuckyWeb::Response)
        return callback_result
      end
    {% end %}
  end

  macro run_after_callbacks
    {% for callback_method in AFTER_CALLBACKS %}
      callback_result = {{ callback_method }}

      ensure_callbacks_return_response_or_continue(callback_result)
      # Callback {{ callback_method }} should return a LuckyWeb::Response or LuckyWeb::ActionCallbacks::Continue
      # Do this by using `continue` or one of rendering methods like `render` or `redirect`
      #
      #   def {{ callback_method }}
      #     cookies["name"] = "John"
      #     continue # or redirect, render
      #   end
      #

      if callback_result.is_a?(LuckyWeb::Response)
        return callback_result
      end
    {% end %}
  end

  def ensure_callbacks_return_response_or_continue(callback_result : LuckyWeb::Response | LuckyWeb::ActionCallbacks::Continue)
  end

  private def continue
    LuckyWeb::ActionCallbacks::Continue.new
  end
end
