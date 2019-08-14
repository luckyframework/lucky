class Lucky::ExceptionPage < ExceptionPage
  def styles : ExceptionPage::Styles
    Styles.new(accent: lucky_green)
  end

  private def lucky_green : String
    "#20c17d"
  end
end
