module Lucky::ActionCallbacks
  # :nodoc:
  class Continue
  end

  # Skips before or after callbacks
  #
  # ```
  # skip require_sign_in, require_organization
  # ```
  macro skip(*callbacks)
    {% for callback in callbacks %}
      {% if BEFORE_CALLBACKS.includes?(callback.id) || AFTER_CALLBACKS.includes?(callback.id) %}
        {% SKIPPED_CALLBACKS << callback.id %}
      {% else %}
        {% callback.raise <<-ERROR.lines.join(" ")
        Can't skip '#{callback}' because the callback is not used.
        Check the spelling of the callback that you are trying to skip.
        ERROR
        %}
      {% end %}
    {% end %}
  end

  # :nodoc:
  macro included
    AFTER_CALLBACKS = [] of Symbol
    BEFORE_CALLBACKS = [] of Symbol
    SKIPPED_CALLBACKS = [] of Symbol

    macro inherited
      AFTER_CALLBACKS = [] of Symbol
      BEFORE_CALLBACKS = [] of Symbol
      SKIPPED_CALLBACKS = [] of Symbol

      inherit_callbacks
    end
  end

  # :nodoc:
  macro inherit_callbacks
    \{% for v in @type.ancestors.first.constant :BEFORE_CALLBACKS %}
      \{% BEFORE_CALLBACKS << v %}
    \{% end %}

    \{% for v in @type.ancestors.first.constant :AFTER_CALLBACKS %}
      \{% AFTER_CALLBACKS << v %}
    \{% end %}

    \{% for v in @type.ancestors.first.constant :SKIPPED_CALLBACKS %}
      \{% SKIPPED_CALLBACKS << v %}
    \{% end %}
  end

  # Run a method before an action is called
  #
  # Methods will run in the order that each `before` is defined. Also, each
  # method must return a `Lucky::Response` like `redirect`, `render`, `json`,
  # etc, or call `continue`:
  #
  # ```crystal
  # class Users::Destroy < BrowserAction
  #   before check_if_signed_in
  #   before confirm_destroy
  #
  #   delete "/:user_id" do
  #     # destroy the user :(
  #   end
  #
  #   def check_if_signed_in
  #     if current_user.nil?
  #       redirect to: SignInPage
  #     else
  #       continue
  #     end
  #   end
  #
  #   def confirm_destroy
  #     # confirm that the user should be destroyed
  #     continue
  #   end
  # end
  # ```
  macro before(method_name)
    {% BEFORE_CALLBACKS << method_name.id %}
  end

  # Run a method after an action ends
  #
  # `after` isn't as common as `before` but can still be useful. One example
  # would be to log a successful transaction to analytics. Methods will run in
  # the order that each `after` is defined. Also, each method must return
  # either a `Lucky::Response` like `redirect`, `render`, `json`, etc, or call
  # `continue`:
  #
  # ```crystal
  # class Purchases::Create < BrowserAction
  #   after log_transaction
  #
  #   route do
  #     # purchase the product
  #   end
  #
  #   def log_transaction
  #     # send the purchase to analytics
  #     continue
  #   end
  # end
  # ```
  macro after(method_name)
    {% AFTER_CALLBACKS << method_name.id %}
  end

  # :nodoc:
  macro run_before_callbacks
    {% callbacks = BEFORE_CALLBACKS.reject { |callback| SKIPPED_CALLBACKS.includes?(callback) } %}

    {% for callback_method in callbacks %}
      callback_result = {{ callback_method }}
      ensure_callbacks_return_response_or_continue(callback_result)
      # Callback {{ callback_method }} should return a Lucky::Response or Lucky::ActionCallbacks::Continue
      # Do this by using `continue` or one of rendering methods like `render` or `redirect`
      #
      #   def {{ callback_method }}
      #     cookies["name"] = "John"
      #     continue # or redirect, render
      #   end

      if callback_result.is_a?(Lucky::Response)
        Lucky::ActionCallbacks.log_stopped_callback(context,"{{ callback_method.id }}")
        return callback_result
      else
        Lucky::ActionCallbacks.log_continued_callback(context,"{{ callback_method.id }}")
      end
    {% end %}
  end

  # :nodoc:
  macro run_after_callbacks
    {% callbacks = AFTER_CALLBACKS.reject { |callback| SKIPPED_CALLBACKS.includes?(callback) } %}

    {% for callback_method in callbacks %}
      callback_result = {{ callback_method }}

      ensure_callbacks_return_response_or_continue(callback_result)
      # Callback {{ callback_method }} should return a Lucky::Response or Lucky::ActionCallbacks::Continue
      # Do this by using `continue` or one of rendering methods like `render` or `redirect`
      #
      #   def {{ callback_method }}
      #     cookies["name"] = "John"
      #     continue # or redirect, render
      #   end

      if callback_result.is_a?(Lucky::Response)
        Lucky::ActionCallbacks.log_stopped_callback(context,"{{ callback_method.id }}")
        return callback_result
      else
        Lucky::ActionCallbacks.log_continued_callback(context,"{{ callback_method.id }}")
      end
    {% end %}
  end

  # :nodoc:
  def self.log_stopped_callback(
    context : HTTP::Server::Context,
    callback_method_name : String
  ) : Void
    Lucky.logger.warn({stopped_by: callback_method_name})
  end

  # :nodoc:
  def self.log_continued_callback(
    context : HTTP::Server::Context,
    callback_method_name : String
  ) : Void
    Lucky.logger.debug({ran: callback_method_name})
  end

  # :nodoc:
  def ensure_callbacks_return_response_or_continue(callback_result : Lucky::Response | Lucky::ActionCallbacks::Continue)
  end

  private def continue
    Lucky::ActionCallbacks::Continue.new
  end
end
