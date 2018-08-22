module CleanupHelper
  private def cleanup
    FileUtils.rm_rf("./tmp")
  end

  private def with_cleanup
    Dir.mkdir_p("./tmp")
    Dir.cd("./tmp")
    yield
  ensure
    Dir.cd("..")
    cleanup
  end
end
