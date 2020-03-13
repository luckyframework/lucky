class Lucky::Paginator::Page
  def_equals number
  getter number

  def initialize(@pages : Lucky::Paginator, @number : Int32 | Int64)
  end

  def path
    @pages.path_to_page(number)
  end
end
