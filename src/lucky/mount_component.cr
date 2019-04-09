module Lucky::MountComponent
  def mount(component : Lucky::BaseComponent) : Nil
    print_component_comment(component)
    component.view(view).render
  end

  def mount(component : Lucky::BaseComponent) : Nil
    print_component_comment(component)
    component.view(view).render do |*yield_args|
      yield *yield_args
    end
  end

  private def print_component_comment(component : Lucky::BaseComponent)
    if Lucky::HTMLPage.settings.render_component_comments
      raw "<!-- Rendered by #{component.class.name} -->"
    end
  end
end
