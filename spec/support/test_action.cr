abstract class TestAction < Lucky::Action
  include Lucky::EnforceUnderscoredRoute
  include Lucky::TurboLinksActionSupport

  accepted_formats [:html], default: :html
end
