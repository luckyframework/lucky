class Tasks::IndexAction < LuckyWeb::Action
  def call
    render
  end
end

class Tasks::NewAction < LuckyWeb::Action
  def call
    render
  end
end

class Tasks::ShowAction < LuckyWeb::Action
  def call
    render_text("Show action")
  end
end

# A different resource

class MyUsers::IndexAction < LuckyWeb::Action
  def call
    render_text("users")
  end
end
