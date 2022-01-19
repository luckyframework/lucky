abstract class TestAction < Lucky::Action
  include Lucky::EnforceUnderscoredRoute
  accepted_formats [:html], default: :html
end
