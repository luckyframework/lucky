class ErrorAction < LuckyWeb::ErrorAction
  def handle_error(error : Exception)
    render_text "Ruh-roh"
  end
end
