module Lucky::MountComponent
  def mount(component, *args, **named_args)
    component.new(@view, *args, **named_args).render
  end

  def mount(component : T, *args, **named_args, &block : T::RenderableProc) forall T
    component.new(@view, *args, **named_args, block: block).render
  end
end
