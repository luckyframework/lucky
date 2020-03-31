module Lucky::UrlHelpers
  # Tests if the given path matches the current request path.
  #
  # ```
  # # Let's say we are visiting https://example.com/shop/products?order=desc&page=1
  # current_page?("/shop/checkout")
  # # => false
  # current_page?("/shop/products")
  # # => true
  # current_page?("/shop/products/")
  # # => true
  # current_page?("/shop/products?order=desc&page=1")
  # # => false
  # current_page?("/shop/products?order=desc&page=1", check_query_params: true)
  # # => true
  # current_page?("https://example.com/shop/products")
  # # => true
  # current_page?("https://example.com/shop/products?order=desc&page=1")
  # # => false
  # ```
  def current_page?(
    path : String,
    check_query_params : Bool = false
  )
    return false unless {"GET", "HEAD"}.includes?(@context.request.method)

    uri = URI.parse(path)

    if check_query_params
      resource = @context.request.resource
      path = uri.full_path
    else
      resource = URI.parse(@context.request.resource).path
      path = uri.path
    end

    unless path == '/'
      path = path.chomp('/')
      resource = resource.chomp('/')
    end

    path == resource
  end

  # Tests if the given path matches the current request path.
  #
  # ```
  # # Visiting https://example.com/pages/123
  # current_page?(Pages::Show.with(123))
  # # => true
  # current_page?(Pages::Show.with(456))
  # # => false
  # # Visiting https://example.com/pages
  # current_page?(Pages::Index)
  # # => true
  # current_page?(Blog::Index)
  # # => false
  # ```
  def current_page?(
    action : Class | Lucky::RouteHelper,
    check_query_params : Bool = false
  )
    current_page?(action.path)
  end
end
