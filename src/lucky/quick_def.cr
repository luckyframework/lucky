module Lucky::QuickDef
  macro quick_def(method_name, value)
    def {{ method_name.id }}
      {{ value }}
    end
  end
end
