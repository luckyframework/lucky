module GeneratorHelper
  private def generate(generator : Class, args : Array(String) = [] of String) : IO
    task = generator.new
    task.output = IO::Memory.new
    task.print_help_or_call(args: args)
    task.output
  end

  private def should_create_files_with_contents(io : IO, **files_and_contents)
    files_and_contents.each do |file_location, file_contents|
      File.read(Path[file_location.to_s].to_s).should contain(file_contents)
      io.to_s.should contain(Path[file_location.to_s].to_s)
    end
  end

  private def should_generate_migration(named name : String)
    Dir.new("./db/migrations").any?(&.ends_with?(name)).should be_true
  end

  private def should_generate_migration(named name : String, with content : String)
    filename = Dir.new("./db/migrations").find(&.ends_with?(name))
    filename.should_not be_nil
    File.read("./db/migrations/#{filename}").should contain(content)
  end

  private def should_have_generated(text : String, inside : String)
    File.read(inside).should contain(text)
  end
end
