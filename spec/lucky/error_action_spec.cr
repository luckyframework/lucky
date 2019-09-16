require "../spec_helper"

include ContextHelper

private class Special
end

private class FakeErrorAction < Lucky::ErrorAction
  default_format :html

  def render(error : Exception) : Lucky::Response
    plain_text "This is not a debug page", status: 500
  end
end

describe Lucky::ErrorAction do
end
