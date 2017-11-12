class Tasks::NewPage
  include LuckyWeb::HTMLPage

  def render
    header({class: "WHAT"}) do
      text "New HTML"
      a "back to index", href: Tasks::Index.path
    end
  end
end
