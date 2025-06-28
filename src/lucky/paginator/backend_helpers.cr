module Lucky::Paginator::BackendHelpers
  # Call this in your actions to paginate an array.
  #
  # This method will return a `Lucky::Paginator` object and the requested page
  # of items.
  #
  # ## Examples
  #
  # ```
  # class ListItems::Index < BrowserAction
  #   get "/items" do
  #     # The 'Array' will just show items for the requested page
  #     pages, items = paginate_array([1, 2, 3])
  #     render IndexPage, pages: pages, items: items
  #   end
  # end
  #
  # class Users::IndexPage < MainLayout
  #   needs pages : Lucky::Paginator
  #   needs items : Array(Int32)
  #
  #   def content
  #     # Render pagination links for the 'items' Array
  #     mount Lucky::Paginator::SimpleNav, @pages
  #   end
  # end
  # ```
  def paginate_array(
    items : Array(T),
    per_page : Int32 = paginator_per_page
  ) : Tuple(Paginator, Array(T)) forall T
    pages = Paginator.new \
      page: paginator_page,
      per_page: per_page,
      item_count: items.size,
      full_path: context.request.resource

    return {pages, Array(T).new} if pages.overflowed?

    updated_items = items[pages.offset...pages.offset + pages.per_page]
    {pages, updated_items}
  end

  # Returns the page that was request, or `1`
  #
  # By default this method looks for a `page` param. It can be given as a
  # query param, or in the body. If no `page` param is given the page will be `1`.
  #
  # You can override this method in your action in any way you'd like.
  #
  # ## Example
  #
  # ```
  # abstract class ApiAction < Lucky::Action
  #   include Lucky::Paginator::BackendHelpers
  #
  #   def paginator_page : Int32
  #     # Will use the "Page" header or fallback to default if missing.
  #     request.headers["Page"]? || super
  #   end
  # end
  # ```
  def paginator_page : Int32
    params.get?(:page).try(&.to_i) || 1
  end

  # The number of records to display per page. Defaults to `25`
  #
  # You can override this in your actions
  #
  # ## Example
  #
  # ```
  # abstract class BrowserAction < Lucky::Action
  #   include Lucky::Paginator::BackendHelpers
  #
  #   # Set to a new static value
  #   def paginator_per_page : Int32
  #     50 # defaults to 25
  #   end
  #
  #   # Or you could allow setting the number from a param
  #   def paginator_per_page : Int32
  #     params.get?(:per_page).try(&.to_i) || 25
  #   end
  # end
  # ```
  def paginator_per_page : Int32
    # Override this to set something custom or allow a param to be set
    25
  end
end
