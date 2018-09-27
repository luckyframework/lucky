module Enigma::Log
  def log(text : String)
    # FileUtils.mkdir_p("log")
    # filename = "log/enigma"
    # file = if ::File.exists?(filename)
    #          ::File.read(filename)
    #        else
    #          ::File.write(filename, "")
    #          ""
    #        end
    # updated_file = file + text + "\n"
    # ::File.write(filename, updated_file)
  end
end
