module Lucky::MountComponent
  def mount(component : Lucky::BaseComponent)
    component.view(view).render
  end

  def mount(component : Lucky::BaseComponent)
    component.view(view).render do |*yield_args|
      yield *yield_args
    end
  end
end
