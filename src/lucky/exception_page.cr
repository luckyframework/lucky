class Lucky::ExceptionPage < ExceptionPage
  def styles
    Styles.new(accent: lucky_green)
  end

  private def lucky_green
    "#20c17d"
  end
end
