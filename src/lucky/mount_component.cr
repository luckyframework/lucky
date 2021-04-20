module Lucky::MountComponent
  # Appends the `component` to the view.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # m(MyComponent)
  # m(MyComponent, with_args: 123)
  # ```
  @[Deprecated("Use `#mount` instead. Example: mount(MyComponent, arg1: 123)")]
  def m(component : Lucky::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args).view(view).render
    end
  end

  # Appends the `component` to the view. Takes a block, and yields the
  # args passed to the component.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # m(MyComponent, name: "Jane") do |name|
  #   text name.upcase
  # end
  # ```
  @[Deprecated("Use `#mount` instead. Example: mount(MyComponent, arg1: 123) do/end")]
  def m(component : Lucky::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args).view(view).render do |*yield_args|
        yield *yield_args
      end
    end
  end

  # Appends the `component` to the view.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # mount(MyComponent)
  # mount(MyComponent, with_args: 123)
  # ```
  def mount(component : Lucky::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args).view(view).render
    end
  end

  # Appends the `component` to the view. Takes a block, and yields the
  # args passed to the component.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # mount(MyComponent, name: "Jane") do |name|
  #   text name.upcase
  # end
  # ```
  def mount(component : Lucky::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args).view(view).render do |*yield_args|
        yield *yield_args
      end
    end
  end

  # :nodoc:
  def mount(_component : Lucky::BaseComponent, *args, **named_args) : Nil
    {% raise <<-ERROR
        'mount' requires a component class, not an instance of a component.

        Try this...

           ▸ mount MyComponent
           ▸ mount_instance MyComponent.new
           ▸ mount_with_defaults MyComponent
        ERROR
    %}
  end

  # :nodoc:
  def mount(_component : Lucky::BaseComponent, *args, **named_args, &) : Nil
    {% raise <<-ERROR
        'mount' requires a component class, not an instance of a component.

        Try this...

           ▸ mount MyComponent
           ▸ mount_instance MyComponent.new
           ▸ mount_with_defaults MyComponent
        ERROR
    %}
  end

  # :nodoc:
  def mount_instance(_component : Lucky::BaseComponent.class) : Nil
    {% raise <<-ERROR
        'mount_instance' requires an instance of a component, not component class.

        Try this...

           ▸ mount MyComponent
           ▸ mount_instance MyComponent.new
           ▸ mount_with_defaults MyComponent
        ERROR
    %}
  end

  # :nodoc:
  def mount_instance(_component : Lucky::BaseComponent.class, &) : Nil
    {% raise <<-ERROR
        'mount_instance' requires an instance of a component, not component class.

        Try this...

           ▸ mount MyComponent
           ▸ mount_instance MyComponent.new
           ▸ mount_with_defaults MyComponent
        ERROR
    %}
  end

  # Appends the `component` to the view.
  # The `component` is a previously initialized instance of a component.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # component = MyComponent.new(name: "Jane")
  # mount_instance(component)
  # ```
  def mount_instance(component : Lucky::BaseComponent) : Nil
    print_component_comment(component.class) do
      component.view(view).render
    end
  end

  # Appends the `component` to the view. Takes a block, and yields the
  # args passed to the component.
  # The `component` is a previously initialized instance of a component.
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # component = MyComponent.new(name: "Jane")
  # mount_instance(component) do |name|
  #   text name.upcase
  # end
  # ```
  def mount_instance(component : Lucky::BaseComponent) : Nil
    print_component_comment(component.class) do
      component.view(view).render do |*yield_args|
        yield *yield_args
      end
    end
  end

  # :nodoc:
  def mount_with_defaults(_component : Lucky::BaseComponent.class) : Nil
    {% raise <<-ERROR
        'mount_with_defaults' requires an instance of a component, not component class.

        Try this...

           ▸ mount MyComponent
           ▸ mount_instance MyComponent.new
           ▸ mount_with_defaults MyComponent
        ERROR
    %}
  end

  # :nodoc:
  def mount_with_defaults(_component : Lucky::BaseComponent.class, &) : Nil
    {% raise <<-ERROR
        'mount_with_defaults' requires an instance of a component, not component class.

        Try this...

           ▸ mount MyComponent
           ▸ mount_instance MyComponent.new
           ▸ mount_with_defaults MyComponent
        ERROR
    %}
  end

  # Appends the `component` to the view.
  #
  # Includes the following common `needs` arguments:
  # * `context`
  # * `current_user`
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # mount_with_defaults(MyComponent)
  # mount_with_defaults(MyComponent, with_args: 123)
  # ```
  def mount_with_defaults(component : Lucky::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args, context: @context, current_user: current_user).view(view).render
    end
  end

  # Appends the `component` to the view. Takes a block, and yields the
  # args passed to the component.
  #
  # Includes the following common `needs` arguments:
  # * `context`
  # * `current_user`
  #
  # When `Lucky::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # mount_with_defaults(MyComponent, name: "Jane") do |name|
  #   text name.upcase
  # end
  # ```
  def mount_with_defaults(component : Lucky::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args, context: @context, current_user: current_user).view(view).render do |*yield_args|
        yield *yield_args
      end
    end
  end

  private def print_component_comment(component : Lucky::BaseComponent.class) : Nil
    if Lucky::HTMLPage.settings.render_component_comments
      raw "<!-- BEGIN: #{component.name} #{component.file_location} -->"
      yield
      raw "<!-- END: #{component.name} -->"
    else
      yield
    end
  end
end
