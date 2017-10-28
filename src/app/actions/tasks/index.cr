class Tasks::Index < LuckyWeb::Action
  action do
    # Uncomment to try out the ErrorAction
    # raise "WUT"
    render tasks: TaskRows.all
  end
end
