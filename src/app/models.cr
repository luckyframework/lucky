class Task
  def title
    "This is my task title"
  end

  def id
    "test-id"
  end
end

class TaskRows
  def self.all
    [Task.new]
  end
end
