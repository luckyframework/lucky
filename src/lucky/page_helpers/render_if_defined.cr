module Lucky::RenderIfDefined
  macro render_if_defined(method_name)
    if self.responds_to?(:{{ method_name.id }})
      self.{{ method_name.id }}()
    end
  end
end
