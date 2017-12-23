class ErrorAction < Lucky::ErrorAction
  def handle_error(error : Exception)
    text "Ruh-roh"
  end
end
