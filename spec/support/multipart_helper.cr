module MultipartHelper
  alias Parts = Hash(String, String | Hash(String, String) | Array(Hash(String, String)) | Array(String))

  BLANK_PART = {} of String => String

  private def build_multipart_request(form_parts : Parts = BLANK_PART,
                                      file_parts : Parts = BLANK_PART)
    form_io, content_type = IO::Memory.new, ""
    HTTP::FormData.build(form_io) do |formdata|
      content_type = formdata.content_type
      form_parts.each do |key, value|
        multipart_form_part(formdata, key, value)
      end
      file_parts.each do |key, value|
        multipart_file_part(formdata, key, value)
      end
    end
    build_request(method: "POST", body: form_io.to_s, content_type: content_type)
  end

  private def multipart_form_part(formdata : HTTP::FormData::Builder, name : String, value : String)
    formdata.field(name, value)
  end

  private def multipart_form_part(formdata : HTTP::FormData::Builder, name : String, value : Hash(String, String))
    value.each do |key, nested_value|
      nested_name = name + ":" + key
      multipart_form_part(formdata, nested_name, nested_value)
    end
  end

  private def multipart_form_part(formdata : HTTP::FormData::Builder, name : String, value : Array(Hash(String, String)))
    value.each_with_index do |nested_part, index|
      nested_part.each do |nested_key, nested_value|
        nested_name = "#{name}[#{index}]:#{nested_key}"
        multipart_form_part(formdata, nested_name, nested_value)
      end
    end
  end

  private def multipart_form_part(formdata : HTTP::FormData::Builder, name : String, value : Array(String))
    value.each do |val|
      formdata.field(name + "[]", val)
    end
  end

  private def multipart_file_part(formdata : HTTP::FormData::Builder, name : String, value : String)
    file_io = IO::Memory.new(value)
    metadata = HTTP::FormData::FileMetadata.new(filename: name)
    headers = HTTP::Headers{"Content-Type" => "text/plain"}
    formdata.file(name, file_io, metadata, headers)
  end

  private def multipart_file_part(formdata : HTTP::FormData::Builder, name : String, value : Hash(String, String))
    value.each do |key, nested_value|
      nested_name = name + ":" + key
      multipart_file_part(formdata, nested_name, nested_value)
    end
  end

  private def multipart_file_part(formdata : HTTP::FormData::Builder, name : String, value : Array(String))
    value.each do |val|
      multipart_file_part(formdata, name + "[]", val)
    end
  end
end
