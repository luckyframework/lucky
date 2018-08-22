module Lucky::MountComponent
  def mount(component, *args, **named_args)
    component.new(@view, *args, **named_args).render
  end

  def mount(component, *args, **named_args)
    component.new(@view, *args, **named_args).render do |*yield_args|
      yield *yield_args
    end
  end
end
