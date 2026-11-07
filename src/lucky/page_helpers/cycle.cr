module Lucky::TextHelpers
  class Cycle
    @values : Array(String)
    getter :values
    @index = 0

    def initialize(*values)
      string_values = Array(String).new
      values.each { |v| string_values << v.to_s }
      @values = string_values
      reset
    end

    def initialize(values : Array(String))
      @values = Array(String).new
      @values = values
      reset
    end

    def reset : Int32
      @index = 0
    end

    def current_value : String
      @values[previous_index]?.to_s
    end

    def to_s(io : IO)
      io << @values[@index]?
      @index = next_index
    end

    private def next_index : Int32
      step_index(1)
    end

    private def previous_index : Int32
      step_index(-1)
    end

    private def step_index(n : Int32) : Int32
      (@index + n) % @values.size
    end
  end
end
