module Lucky::RequestBodyLimit
  macro included
    def self.request_body_limit : Int64?
      nil
    end
  end

  macro set_request_body_limit(bytes)
    def self.request_body_limit : Int64?
      ({{ bytes }}).to_i64
    end
  end

  macro clear_request_body_limit
    def self.request_body_limit : Int64?
      nil
    end
  end
end
