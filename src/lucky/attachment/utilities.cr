module Lucky::Attachment
  # Utility to work with a file IO. If the IO is already a File, yields it
  # directly, Otherwise copies to a tempfile, yields it, then cleans up.
  #
  # ```
  # Lucky::Attachment.with_file(io) do |file|
  #   # file is guaranteed to be a File with a path
  # end
  # ```
  #
  def self.with_file(io : IO, &)
    if io.is_a?(File)
      yield io
    else
      File.tempfile("lucky-attachment") do |tempfile|
        IO.copy(io, tempfile)
        tempfile.rewind
        yield tempfile
      end
    end
  end

  def self.with_file(uploaded_file : StoredFile, &)
    uploaded_file.download do |tempfile|
      yield tempfile
    end
  end
end
