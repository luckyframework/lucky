module Avram
  class InvalidOperationError < AvramError
    include Lucky::RenderableError

    def renderable_status : Int32
      400
    end

    def renderable_message : String
      "Invalid params"
    end

    def renderable_details : String
      "#{invalid_attribute_name} #{validation_messages.first}"
    end

    def invalid_attribute_name : String
      invalid_attribute[0].to_s
    end

    private def validation_messages
      invalid_attribute[1]
    end

    private def invalid_attribute
      errors.first
    end
  end
end
