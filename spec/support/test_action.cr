abstract class TestAction < Lucky::Action
  accepted_formats [:html], default: :html
end
