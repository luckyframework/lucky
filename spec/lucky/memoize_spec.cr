require "../spec_helper"

include ContextHelper

class OnlyMemoize < Lucky::Action
  @i = 0
  memoize def long_task : Int32
    proc = ->{ @i += 1 }
    proc.call
  end

  get "/memoize/one" do
    long_task
    text long_task.to_s
  end
end

class MultiMemoize < Lucky::Action
  memoize def task_one : String
    "running task_one"
  end

  memoize def task_two : Time
    Time.utc
  end

  get "/memoize/multi" do
    task_one
    task_two
    text "Still works"
  end
end

class MemoizeOnPage < Lucky::Action
  @seed = 0
  memoize def big_data : Int32
    proc = ->{ @seed += 1 }
    proc.call
  end

  expose big_data

  get "/memoze/on-page" do
    render MemoizePage
  end
end

class MemoizePage
  include Lucky::HTMLPage

  needs big_data : Int32

  def render
    h1 @big_data.to_s
    h2 @big_data.to_s
    h3 @big_data.to_s
    h4 @big_data.to_s
    h5 @big_data.to_s
  end
end

describe "memoizations" do
  it "only calls the long_task once" do
    response = OnlyMemoize.new(build_context, params).call
    response.body.should contain "1"
  end

  it "has no conflicts when memoizing numerous methods" do
    response = MultiMemoize.new(build_context, params).call
    response.body.should contain "Still works"
  end

  it "can expose and pass memoized method to page" do
    data = MemoizeOnPage.new(build_context, params).big_data
    MemoizePage.new(build_context, big_data: data).render.to_s.should contain %(<h5>1</h5>)
  end
end
