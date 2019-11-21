# This file depends on spec/test_action.cr being available first, so the name matters.
# If the name changes you may need to require ./spec/test_action.cr
class TestFallbackAction::Index < TestAction
  fallback do
    plain_text "You found me"
  end
end
