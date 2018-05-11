module GeneratorHelper
  private def should_create_files_with_contents(io : IO, **files_and_contents)
    files_and_contents.each do |file_location, file_contents|
      File.read(file_location.to_s).should contain(file_contents)
      io.to_s.should contain(file_location.to_s)
    end
  end
end
