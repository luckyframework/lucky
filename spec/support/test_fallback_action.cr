class TestFallbackAction::Index < TestAction
  fallback do
    plain_text "You found me"
  end
end
