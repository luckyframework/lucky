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
  # # => true
  # current_page?("/shop/products", check_query_params: true)
  # # => false
  # current_page?("/shop/products?order=desc&page=1", check_query_params: true)
  # # => true
  # current_page?("https://example.com/shop/products")
  # # => true
  # current_page?("https://example.io/shop/products")
  # # => false
  # current_page?("https://example.com/shop/products", check_query_params: true)
  # # => false
  # current_page?("https://example.com/shop/products?order=desc&page=1")
  # # => true
  # ```
  def current_page?(
    value : String,
    check_query_params : Bool = false
  ) : Bool
    request = @context.request

    return false unless {"GET", "HEAD"}.includes?(request.method)

    uri = URI.parse(value)
    request_uri = URI.parse(request.resource)
    path = uri.path
    resource = request_uri.path

    unless path == "/"
      path = path.chomp("/")
      resource = resource.chomp("/")
    end

    if check_query_params
      path += comparable_query_params(uri.query_params)
      resource += comparable_query_params(request_uri.query_params)
    end

    if value.match(/^\w+:\/\//)
      host_with_port = uri.port ? "#{uri.host}:#{uri.port}" : uri.host
      "#{host_with_port}#{path}" == "#{request.headers["Host"]?}#{resource}"
    else
      path == resource
    end
  end

  # Tests if the given path matches the current request path.
  #
  # ```
  # # Visiting https://example.com/pages/123
  # current_page?(Pages::Show.with(123))
  # # => true
  # current_page?(Posts::Show.with(123))
  # # => false
  # # Visiting https://example.com/pages
  # current_page?(Pages::Index)
  # # => true
  # current_page?(Blog::Index)
  # # => false
  # # Visiting https://example.com/pages?page=2
  # current_page?(Pages::Index.with)
  # # => true
  # current_page?(Pages::Index.with(page: 2))
  # # => true
  # current_page?(Pages::Index.with, check_query_params: true)
  # # => false
  # current_page?(Pages::Index.with(page: 2), check_query_params: true)
  # # => true
  # ```
  def current_page?(
    action : Lucky::Action.class | Lucky::RouteHelper,
    check_query_params : Bool = false
  ) : Bool
    current_page?(action.path, check_query_params)
  end

  private def comparable_query_params(query_params : HTTP::Params) : String
    URI.decode(query_params.map(&.join).sort!.join)
  end
end
