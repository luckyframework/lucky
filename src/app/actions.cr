class Tasks::Index < LuckyWeb::Action
  action do
    render tasks: TaskRows.all
  end
end

class Tasks::New < LuckyWeb::Action
  action do
    render
  end
end

class Tasks::Show < LuckyWeb::Action
  action do
    render_text("Show action")
  end
end

# A different resource

class MyUsers::Index < LuckyWeb::Action
  action do
    render_text("users")
  end
end
