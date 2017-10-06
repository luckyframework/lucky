module LuckyWeb::ActionCallbacks
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
      if callback_result.is_a?(LuckyWeb::Response)
        return callback_result
      end
    {% end %}
  end

  macro run_after_callbacks
    {% for callback_method in AFTER_CALLBACKS %}
      callback_result = {{ callback_method }}
      if callback_result.is_a?(LuckyWeb::Response)
        return callback_result
      end
    {% end %}
  end
end
