class Lucky::Paginator
  @page : Int32
  getter per_page : Int32
  getter item_count : Int32 | Int64
  getter full_path : String

  alias SeriesItem = Gap | Page | CurrentPage

  def initialize(@page, @per_page, @item_count, @full_path)
  end

  # Returns the current page. Return `1` if the passed in `page` is lower than `1`.
  def page : Int32
    if @page < 1
      @page = 1
    else
      # Later: Make option to raise if 'overflowed?'
      @page
    end
  end

  # Returns `true` if there is just one page.
  def one_page? : Bool
    total == 1
  end

  def offset : Int32
    per_page * (page - 1)
  end

  # Returns the total number of pages.
  def total : Int64
    (item_count / per_page).ceil.to_i64
  end

  # Returns `true` if current `page` is the last one.
  def last_page? : Bool
    page == total
  end

  # Returns `true` if the current `page` is the first one.
  def first_page? : Bool
    page == 1
  end

  # Returns `true` if the current `page` is past the last page.
  def overflowed? : Bool
    page > total
  end

  # Returns the `Range` of items on this page.
  #
  # For example if you have 50 records, showing 20 per page, and
  # you are on the 2nd page this method will return a range of 21-40.
  #
  # You can get the beginning and end by calling `begin` or `end` on the
  # returned `Range`.
  def item_range : Range
    starting_item_number = ((page - 1) * per_page) + 1
    ending_item_number = [(starting_item_number + per_page - 1), item_count].min
    Range.new(starting_item_number, ending_item_number)
  end

  # Returns the previous page number or nil if the current page is the first one.
  def previous_page : Int32?
    page - 1 unless first_page?
  end

  # Returns the next page number or nil if the current page is the last one.
  def next_page : Int32?
    page + 1 unless last_page? || overflowed?
  end

  # Returns the path with a 'page' query param for the previous page.
  #
  # Return nil if there is no previous page
  def path_to_previous : String?
    if page_number = previous_page
      path_to_page(page_number)
    end
  end

  # Returns the path with a 'page' query param for the previous page.
  #
  # Return nil if there is no previous page
  def path_to_next : String?
    if page_number = next_page
      path_to_page(page_number)
    end
  end

  # Generate a page with the 'page' query param set to the passed in `page_number`.
  #
  # ## Examples
  #
  # ```
  # pages = Paginator.new(
  #   page: 1,
  #   per_page: 25,
  #   item_count: 70,
  #   full_path: "/comments"
  # )
  # pages.path_to_page(2) # "/comments?page=2"
  # ```
  def path_to_page(page_number : Int) : String
    uri = URI.parse(full_path)
    query_params = uri.query_params
    query_params["page"] = page_number.to_s
    uri.query = query_params.to_s
    uri.to_s
  end

  # Returns a series of pages and gaps
  #
  # This method calculates a series of pages and gaps based on how many pages
  # there are, and what the current page is. It uses the
  # `begin|left_of_current|right_of_current|end` arguments to customize the returned
  # series of pages and gaps. The series is made up of `Lucky::Paginator::Gap`,
  # `Lucky::Paginator::Page` and `Lucky::Paginator::CurrentPage` objects.
  #
  # The best way to describe how this works is with an example. Let's say you
  # have 10 pages of items and you are requesting page 5.
  #
  # > Note we will simplify the objects by using integers and ".." in place of the
  # > `Gap|Page|CurrentPage` objects. We'll show an example with the real
  # objects further down
  #
  # ```
  # series = pages.series(begin: 1, left_of_current: 1, right_of_current: 1, end: 1)
  # series # [1, .., 4, 5, 6, .., 10]

  # # All args default to 0 so you can leave them off. That means `begin|end`
  # # are 0 in this example.
  # series = pages.series(left_of_current: 1, right_of_current: 1)
  # series # [4, 5, 6]

  # # The current page is always shown
  # series = pages.series(begin: 2, end: 2)
  # series # [1, 2, .., 5, .., 9, 10]

  # # The `series` method is smart and will not add gaps if there is no gap.
  # # It will also not add items past the current page.
  # series = pages.series(begin: 6)
  # series # [1, 2, 3, 4, 5]
  # ```
  #
  # As mentioned above the **actual** objects in the Array are made up of
  # `Lucky::Paginator::Gap`, `Lucky::Paginator::Page`, and
  # `Lucky::Paginator::CurrentPage` objects.
  #
  # ```
  # pages.series(begin: 1, end: 1)
  # # Returns:
  # # [
  # #   Lucky::Paginator::Page(1),
  # #   Lucky::Paginator::Gap,
  # #   Lucky::Paginator::CurrentPage(5),
  # #   Lucky::Paginator::Gap,
  # #   Lucky::Paginator::Page(10),
  # # ]
  # ```
  #
  # The `Page` and `CurrentPage` objects have a `number` and `path` method.
  # `Page#number` returns the number of the page as an Int. The `Page#path` method
  # Return the path to the next page.
  #
  # The `Gap` object has no methods or instance variables. It is there to
  # represent a "gap" of pages.
  #
  # These objects make it easy to use [method # overloading](https://crystal-lang.org/reference/syntax_and_semantics/overloading.html)
  # or `is_a?` to determine how to render each item.
  #
  # Here's a quick example:
  #
  # ```
  # pages.series(begin: 1, end: 1).each do |item|
  #   case item
  #   when Lucky::Paginator::CurrentPage | Lucky::Paginator::Page
  #     pp! item.number # Int32 representing the page number
  #     pp! item.path   # "/items?page=2"
  #   when Lucky::Paginator::Gap
  #     puts "..."
  #   end
  # end
  # ```
  #
  # Or use method overloading. This will show an example using Lucky's HTML methods:
  #
  # ```
  # class PageNav < BaseComponent
  #   needs pages : Lucky::Paginator
  #
  #   def render
  #     pages.series(begin: 1, end: 1).each do |item|
  #       page_item(item)
  #     end
  #   end
  #
  #   def page_item(page : Lucky::Paginator::CurrentPage)
  #     # If it is the current page, just display text and no link
  #     text page.number
  #   end
  #
  #   def page_item(page : Lucky::Paginator::CurrentPage)
  #     a page.number, href: page.path
  #   end
  #
  #   def page_item(gap : Lucky::Paginator::Gap)
  #     text ".."
  #   end
  # end
  # ```
  def series(
    begin beginning : Int32 = 0,
    left_of_current : Int32 = 0,
    right_of_current : Int32 = 0,
    end ending : Int32 = 0
  ) : Array(SeriesItem)
    middle_pages = build_middle_of_series(left_of_current, right_of_current)
    beginning_and_middle_pages = add_beginning_pages(middle_pages, beginning)
    add_ending_pages(beginning_and_middle_pages, ending)
  end

  private def build_middle_of_series(
    left_of_current : Int32,
    right_of_current : Int32
  ) : Array(SeriesItem)
    arr = [] of SeriesItem

    # If given `left_of_current: 2` this would yield `2` then `1`
    # If 0 it will not yield anything
    left_of_current.downto(1) do |i|
      # And page number would be `page - 2` then `page - 1`
      # So if you are on page `10` you'd have `8`, then `9`
      page_number = page - i
      # Don't add a 0 or - page.
      if page_number >= 1
        arr << Page.new(self, page_number)
      end
    end

    # Always add the current page
    arr << CurrentPage.new(self, page)

    # If given `right_of_current: 2` it would yield `1` then `2`
    # If 0 it will not yield anything
    1.upto(right_of_current) do |i|
      # This would be `page + 1` then `page + 2`, etc.
      # So if you are on page `10` and there are `15` pages you'd have `11` then `12`
      page_number = page + i # + 1
      # Don't add the page if it is greater than the total pages
      # So if you're on page `10` with a total of `10` pages it will not add pages
      # to the rigth
      if page_number <= total
        arr << Page.new(self, page_number)
      end
    end

    arr
  end

  private def add_beginning_pages(arr : Array(SeriesItem), beginning : Int32) : Array(SeriesItem)
    first_page_in_middle_section = (arr.first.as(Page).number)

    # If beginning is set to 2 and the first page in the middle section is 4 add Gap: 2, .., 4
    # If beginning is set to 2 and the first page in the middle section is 3, don't: 2, 3
    if beginning > 0 && (beginning + 1) < first_page_in_middle_section
      arr.unshift Gap.new
    end

    # If beginning is 2 it'll count from 2 down to 1. So it'll yield 2, then 1
    beginning.downto(1) do |i|
      page_number = i
      if page_number < first_page_in_middle_section
        # Unshift prepends the item to the beginning of the series
        # Since we are counting down this would look something like:
        #
        # [3, 4, 5].unshift(2) # => [2, 3, 4, 5]
        # [2, 3, 4, 5].unshift(1) # => [1, 2, 3, 4, 5]
        arr.unshift Page.new(self, page_number)
      end
    end

    arr
  end

  private def add_ending_pages(arr : Array(SeriesItem), ending : Int32) : Array(SeriesItem)
    last_page_in_middle_section = (arr.last.as(Page).number)

    # First determine the smallest ending page
    # So if total pages is 20 and ending is 2 you'd get 18
    smallest_ending_page = total - ending
    # If smallest ending page is 18 and last page in middle is 20 then do add a gap: 18, .., 20
    # If smallest ending page is 18 and last page in middle is 19 don't add a gap: 19, 20
    if ending > 0 && smallest_ending_page > last_page_in_middle_section
      arr << Gap.new
    end

    # If ending is 2 it'll count from 2 down to 1. So it'll yield 2, then 1
    ending.downto(1) do |i|
      # So if there are 10 total pages this would be `10 + 1 - 2` then `10 + 1 -1`
      # Giving you `9` then `10`
      page_number = total + 1 - i
      if page_number > last_page_in_middle_section
        arr << Page.new(self, page_number)
      end
    end

    arr
  end
end
