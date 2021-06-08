module Lucky::Exposable
  macro included
    EXPOSURES = [] of Symbol

    macro inherited
      EXPOSURES = [] of Symbol

      inherit_exposures
    end
  end

  # :nodoc:
  macro inherit_exposures
    \{% for v in @type.ancestors.first.constant :EXPOSURES %}
      \{% EXPOSURES << v %}
    \{% end %}
  end

  # Sends the result of a method to the page as if it was passed as an argument.
  #
  # Imagine having data that is used by many actions across your app, such
  # as the current user. It can get tedious to pass that data for every action.
  # The `expose` macro will make sure that whatever data you need is passed
  # automatically.
  #
  # Here's what things might look like without `expose`:
  #
  # ```
  # class BrowserAction
  #   def current_user
  #     # some way to find the current user
  #   end
  # end
  # ```
  #
  # Each action must pass `current_user` manually. Note that each action
  # inherits from `BrowserAction` and therefore has access to `current_user`:
  #
  # ```
  # class Messages::Index < BrowserAction
  #   get "/messages" do
  #     html IndexPage, current_user: current_user
  #   end
  # end
  #
  # class Messages::New < BrowserAction
  #   get "/messages/new" do
  #     html NewPage, current_user: current_user
  #   end
  # end
  # ```
  #
  # Passing `current_user: current_user` every time gets pretty old. Enter
  # `expose`:
  #
  # ```
  # class BrowserAction
  #   expose current_user
  #
  #   def current_user
  #     # some way to find the current user
  #   end
  # end
  # ```
  #
  # Now our actions are much nicer, especially when we start to have multiple
  # arguments for each action:
  #
  # ```
  # class Messages::Index < BrowserAction
  #   get "/messages" do
  #     html IndexPage
  #   end
  # end
  #
  # class Messages::New < BrowserAction
  #   get "/messages/new" do
  #     html NewPage
  #   end
  # end
  # ```
  #
  # ## Exposing private methods
  #
  # Also useful is the ability to make a private method available:
  #
  # ```
  # class Messages::Show < BrowserAction
  #   expose message
  #
  #   get "/messages/:id" do
  #     html ShowPage
  #   end
  #
  #   private def message
  #     MessageQuery.find(id)
  #   end
  # end
  # ```
  #
  # Using `expose` here will pass `message` to the `ShowPage`, while keeping the
  # method private. Without `expose` the action would look like this:
  #
  # ```
  # get "/messages/:id" do
  #   html ShowPage, message: message
  # end
  # ```
  macro expose(method_name)
    {% method_name_str = method_name.stringify %}
    {% if method_name_str.ends_with?('?') || method_name_str.ends_with?('!') %}
      {% method_name.raise <<-ERROR

      Methods ending in '?' or '!' cannot be exposed to pages.
      #{@type.name} called `expose #{method_name_str.id}`

      Try this...

        ▸ Define your method without ? or ! then...
        ▸ expose #{method_name_str.gsub(/[!?]$/, "").id}
      ERROR
      %}
    {% end %}
    {% EXPOSURES << method_name.id %}
  end
end
