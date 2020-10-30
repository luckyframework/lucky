module Lucky::QuickDef
  # Quickly create a method with a simple return value
  #
  # ```
  # # Instead of:
  # def name
  #   "Kylo"
  # end
  #
  # # You could use quick_def:
  # quick_def :name, "Kylo"
  # ```
  macro quick_def(method_name, value)
    def {{ method_name.id }}
      {{ value }}
    end
  end
end
