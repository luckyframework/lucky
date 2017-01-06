class Tasks::IndexHTML < LuckyWeb::HTMLView
  def render
    header class: "WHAT" do
      text "Tasks index"
      h1 "DANG"
      br
      br({class: "stuff"})
      br class: "stuff"
      img({src: "someting"})
      h2 "A bit smaller", {class: "peculiar"}
      h6 class: "h6!!!!" do
        small "super tiny", class: "This is cool"
        span "NOICE"
      end
    end
  end
end

class Tasks::NewHTML < LuckyWeb::HTMLView
  def render
    header({class: "WHAT"}) do
      text "New HTML"
    end
  end
end
