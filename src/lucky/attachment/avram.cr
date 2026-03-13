module Avram::Attachment::Model
  macro included
    class ::{{ @type }}::SaveOperation < Avram::SaveOperation({{ @type }})
      include Avram::Attachment::SaveOperation
    end

    macro finished
      class ::{{ @type }}::DeleteOperation < Avram::DeleteOperation({{ @type }})
        include Avram::Attachment::DeleteOperation
      end
    end
  end

  # Registers a serializable column for an attachment and takes and uploader
  # class as the type.
  #
  # ```
  # attach avatar : ImageUploader::StoredFile
  # # or
  # attach avatar : ImageUploader::StoredFile?
  # ```
  #
  # It is assumed that a `jsonb` column exists with the same name. So in your
  # migration, you'll need to add the column as follows:
  #
  # ```
  # add avatar : JSON::Any
  # # or
  # add avatar : JSON::Any?
  # ```
  #
  # The data of a stored file can then be accessed through the `avatar` method:
  #
  # ```
  # user.avatar.class
  # # => ImageUploader::StoredFile
  #
  # user.avatar.url
  # # => "https://bucket.s3.amazonaws.com/user/1/avatar/abc123.jpg"
  #
  # # for presigned URLs
  # user.avatar.url(expires_in: 1.hour)
  # ```
  #
  # The path prefix of an attachment can be customised globally in the
  # settings, but also on attachment level:
  #
  # ```
  # attach avatar : ImageUploader::StoredFile?, path_prefix: ":model/images/:id"
  # ```
  #
  macro attach(type_declaration, path_prefix = nil)
    {% name = type_declaration.var %}
    {% if type_declaration.type.is_a?(Union) %}
      {% stored_file = type_declaration.type.types.first %}
      {% nilable = true %}
    {% else %}
      {% stored_file = type_declaration.type %}
      {% nilable = false %}
    {% end %}
    {% uploader = stored_file.stringify.split("::")[0..-2].join("::").id %}

    # Registers a path prefix for the attachment.
    {% if !@type.constant(:ATTACHMENT_PREFIXES) %}
      ATTACHMENT_PREFIXES = {} of Symbol => String
    {% end %}
    path_prefix = {{ path_prefix }} || ::Lucky::Attachment.settings.path_prefix
    ATTACHMENT_PREFIXES[:{{ name }}] = path_prefix
      .gsub(/:model/, {{ @type.stringify.gsub(/::/, "_").underscore }})
      .gsub(/:attachment/, {{ name.stringify }})

    # Registers the configured uploader class for the attachment.
    {% if !@type.constant(:ATTACHMENT_UPLOADERS) %}
      ATTACHMENT_UPLOADERS = {} of Symbol => ::Lucky::Attachment::Uploader.class
    {% end %}
    ATTACHMENT_UPLOADERS[:{{ name }}] = {{ uploader }}

    column {{ name }} : ::{{ stored_file }}{% if nilable %}?{% end %}, serialize: true
  end
end

module Avram::Attachment::SaveOperation
  # Registers a file attribute for an existing attachment on the model.
  #
  # ```
  # # The field name in the form will be "avatar_file"
  # attach avatar
  #
  # # With a custom field name
  # attach avatar, field_name: "avatar_upload"
  # ```
  #
  # The attachment will then be uploaded to the cache store, and after
  # committing to the database the attachment will be moved to the permanent
  # storage.
  #
  macro attach(name, field_name = nil)
    {%
      field_name = "#{name}_file".id if field_name.nil?

      unless column = T.constant(:COLUMNS).find { |col| col[:name].stringify == name.stringify }
        raise %(The `#{T.name}` model does not have a column named `#{name}`)
      end
    %}

    file_attribute :{{ field_name }}

    {% if nilable = column[:nilable] %}
      attribute delete_{{ name }} : Bool = false
    {% end %}

    before_save __cache_{{ field_name }}
    after_commit __process_{{ field_name }}

    # Moves uploaded file to the cache storage.
    private def __cache_{{ field_name }} : Nil
      {% if nilable %}
        {{ name }}.value = nil if delete_{{ name }}.value
      {% end %}

      return unless upload = {{ field_name }}.value

      record_id = {{ T.constant(:PRIMARY_KEY_NAME).id }}.value
      {{ name }}.value = T::ATTACHMENT_UPLOADERS[:{{ name }}].cache(
        upload.tempfile,
        path_prefix: T::ATTACHMENT_PREFIXES[:{{ name }}].gsub(/:id/, record_id),
        filename:  upload.filename.presence
      )
    end

    # Deletes or promotes the attachment and updates the record.
    private def __process_{{ field_name }}(record) : Nil
      {% if nilable %}
        if delete_{{ name }}.value && (file = {{ name }}.original_value)
          file.delete
        end
      {% end %}

      return unless {{ field_name }}.value && (cached = {{ name }}.value)

      stored = T::ATTACHMENT_UPLOADERS[:{{ name }}].promote(cached)
      T::SaveOperation.update!(record, {{ name }}: stored)
    end
  end
end

module Avram::Attachment::DeleteOperation
  # Cleans up the files of any attachments this records still has.
  macro included
    after_delete do |_|
      {% for name in T.constant(:ATTACHMENT_UPLOADERS) %}
        if attachment = {{ name }}.value
          attachment.delete
        end
      {% end %}
    end
  end
end
