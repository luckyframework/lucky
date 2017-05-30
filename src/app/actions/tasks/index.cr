class Tasks::Index < LuckyWeb::Action
  action do
    render tasks: TaskRows.all
  end
end
