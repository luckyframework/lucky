class Tasks::NewPage
  include LuckyWeb::Page

  render do
    header({class: "WHAT"}) do
      text "New HTML"
      a "back to index", href: Tasks::Index.path
    end
  end
end
