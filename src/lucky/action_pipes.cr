module Lucky::ActionPipes
  # :nodoc:
  class Continue
  end

  # Skips before or after pipes
  #
  # ```
  # skip require_sign_in, require_organization
  # ```
  macro skip(*pipes)
    {% for pipe in pipes %}
      {% if BEFORE_PIPES[pipe.id] || AFTER_PIPES[pipe.id] %}
        {% BEFORE_PIPES[pipe.id] = false %}
        {% AFTER_PIPES[pipe.id] = false %}
      {% else %}
        {% pipe.raise <<-ERROR.lines.join(" ")
          Can't skip '#{pipe}' because the pipe is not used.
          Check the spelling of the pipe that you are trying to skip.
          ERROR
        %}
      {% end %}
    {% end %}
  end

  # :nodoc:
  macro included
    AFTER_PIPES  = {} of Symbol => Bool
    BEFORE_PIPES = {} of Symbol => Bool

    macro inherited
      AFTER_PIPES  = {} of Symbol => Bool
      BEFORE_PIPES = {} of Symbol => Bool

      inherit_pipes
    end
  end

  # :nodoc:
  macro inherit_pipes
    \{% for k, v in @type.ancestors.first.constant :BEFORE_PIPES %}
      \{% BEFORE_PIPES[k] = v %}
    \{% end %}

    \{% for k, v in @type.ancestors.first.constant :AFTER_PIPES %}
      \{% AFTER_PIPES[k] = v %}
    \{% end %}
  end

  # Run a method before an action is called
  #
  # Methods will run in the order that each `before` is defined. Also, each
  # method must return a `Lucky::Response` like `redirect`, `html`, `json`,
  # etc, or call `continue`:
  #
  # ```
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
    {% BEFORE_PIPES[method_name.id] = true %}
  end

  # Run a method after an action ends
  #
  # `after` isn't as common as `before` but can still be useful. One example
  # would be to log a successful transaction to analytics. Methods will run in
  # the order that each `after` is defined. Also, each method must return
  # either a `Lucky::Response` like `redirect`, `html`, `json`, etc, or call
  # `continue`:
  #
  # ```
  # class Purchases::Create < BrowserAction
  #   after log_transaction
  #
  #   post "/purchases" do
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
    {% AFTER_PIPES[method_name.id] = true %}
  end

  # :nodoc:
  macro run_before_pipes
    {% for pipe_method, is_enabled in BEFORE_PIPES %}
      {% if is_enabled %}
        pipe_result = {{ pipe_method }}
        ensure_pipe_return_response_or_continue(pipe_result)
        # Pipe {{ pipe_method }} should return a Lucky::Response or Lucky::ActionPipes::Continue
        # Do this by using `continue` or one of rendering methods like `html` or `redirect`
        #
        #   def {{ pipe_method }}
        #     cookies["name"] = "John"
        #     continue # or redirect, render
        #   end

        if pipe_result.is_a?(Lucky::Response)
          publish_before_event("{{ pipe_method.id }}", continued: false)
          Lucky::ActionPipes.log_halted_pipe("{{ pipe_method.id }}")
          return pipe_result
        else
          publish_before_event("{{ pipe_method.id }}", continued: true)
          Lucky::ActionPipes.log_continued_pipe("{{ pipe_method.id }}")
        end
      {% end %}
    {% end %}
  end

  # :nodoc:
  macro run_after_pipes
    {% for pipe_method, is_enabled in AFTER_PIPES %}
      {% if is_enabled %}
        pipe_result = {{ pipe_method }}

        ensure_pipe_return_response_or_continue(pipe_result)
        # Pipe {{ pipe_method }} should return a Lucky::Response or Lucky::ActionPipes::Continue
        # Do this by using `continue` or one of rendering methods like `html` or `redirect`
        #
        #   def {{ pipe_method }}
        #     cookies["name"] = "John"
        #     continue # or redirect, render
        #   end

        if pipe_result.is_a?(Lucky::Response)
          publish_after_event("{{ pipe_method.id }}", continued: false)
          Lucky::ActionPipes.log_halted_pipe("{{ pipe_method.id }}")
          return pipe_result
        else
          publish_after_event("{{ pipe_method.id }}", continued: true)
          Lucky::ActionPipes.log_continued_pipe("{{ pipe_method.id }}")
        end
      {% end %}
    {% end %}
  end

  # :nodoc:
  def self.log_halted_pipe(pipe_method_name : String) : Nil
    Lucky::Log.dexter.warn { {halted_by: pipe_method_name} }
  end

  # :nodoc:
  def self.log_continued_pipe(pipe_method_name : String) : Nil
    Lucky::ContinuedPipeLog.dexter.info { {ran_pipe: pipe_method_name} }
  end

  # :nodoc:
  def ensure_pipe_return_response_or_continue(pipe_result : Lucky::Response | Lucky::ActionPipes::Continue)
  end

  # Call this in a pipe to continue to the next pipe or action
  def continue : Lucky::ActionPipes::Continue
    Lucky::ActionPipes::Continue.new
  end

  private def publish_before_event(pipe_name : String, continued : Bool)
    Lucky::Events::PipeEvent.publish(
      name: pipe_name,
      position: Lucky::Events::PipeEvent::Position::Before,
      continued: continued
    )
  end

  private def publish_after_event(pipe_name : String, continued : Bool)
    Lucky::Events::PipeEvent.publish(
      name: pipe_name,
      position: Lucky::Events::PipeEvent::Position::After,
      continued: continued
    )
  end
end
