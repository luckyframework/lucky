module Lucky::Paginator::BackendHelpers
  # Call this in your actions to paginate an query.
  #
  # This method will return a `Lucky::Paginator` object and the requested page
  # of records.
  #
  # ## Examples
  #
  # ```crystal
  # class Users::Index < BrowserAction
  #   get "/users" do
  #     # The 'UserQuery' will return just the records for the requested page
  #     # because 'paginate' will add a 'limit' and 'offset' to the query.
  #     pages, users = paginate(UserQuery.new)
  #     render IndexPage, pages: pages, users: users
  #   end
  # end
  #
  # class Users::IndexPage < MainLayout
  #   needs pages : Lucky::Paginator
  #   needs users : UserQuery
  #
  #   def content
  #     # Render 'users' like normal
  #     mount Lucky::Paginator::SimpleNav.new(@pages)
  #   end
  # end
  # ```
  def paginate(
    query : Avram::Queryable(T),
    per_page : Int32 = paginator_per_page
  ) : Tuple(Paginator, Avram::Queryable(T)) forall T
    pages = Paginator.new \
      page: paginator_page,
      per_page: per_page,
      item_count: query.clone.reset_order.reset_limit.reset_offset.select_count,
      full_path: context.request.resource

    updated_query = query.limit(pages.per_page).offset(pages.offset)
    {pages, updated_query}
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
  # ```crystal
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
  # ```crystal
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
