module CleanupHelper
  private def cleanup
    ARGV.clear
    FileUtils.rm_rf("./tmp")
  end

  private def with_cleanup
    Dir.mkdir("./tmp")
    Dir.cd("./tmp")
    yield
  ensure
    Dir.cd("..")
    cleanup
  end
end
