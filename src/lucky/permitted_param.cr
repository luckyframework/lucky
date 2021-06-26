module Lucky
  class PermittedParam(T)
    getter name : String
    getter value : T
    getter param_key : String?

    def initialize(*, @name : String, @value : T, @param_key : String? = nil)
    end

    def param_name : String
      String.build do |str|
        str << "#{param_key}:" if param_key
        str << name
        str << "[]" if T.is_a?(Array.class)
      end
    end
  end
end
