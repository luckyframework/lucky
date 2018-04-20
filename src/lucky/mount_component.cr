module Lucky::MountComponent
  def mount(component, *args, **named_args)
    component.new(self, *args, **named_args).render
  end
end
