# Extractors try to extract metadata from the context they're given: the `IO`
# object, the current state of the resulting metadata hash, or arbitrary
# options passed to the `upload` method of the uploader.
#
module Lucky::Attachment::Extractor
  # Extracts metadata and returns a `MetadataValue`. Alternatively, the
  # metadata hash may be modified directly if multiple values need to be added
  # (e.g. the dimensions of an image).
  #
  abstract def extract(
    uploaded_file : Lucky::UploadedFile,
    metadata : MetadataHash,
    **options,
  ) : MetadataValue?
end
