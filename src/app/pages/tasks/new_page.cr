class Tasks::NewPage < LuckyWeb::Page
  def render
    header({class: "WHAT"}) do
      text "New HTML"
      a "back to index", href: Tasks::Index.path
    end
  end
end
