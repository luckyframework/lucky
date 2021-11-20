module Lucky::Paginator::BackendHelpers
  # Call this in your actions to paginate an query.
  #
  # This method will return a `Lucky::Paginator` object and the requested page
  # of records.
  #
  # ## Examples
  #
  # ```
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
  #     mount Lucky::Paginator::SimpleNav, @pages
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
end
