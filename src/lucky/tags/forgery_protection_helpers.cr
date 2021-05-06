module Lucky::ForgeryProtectionHelpers
  # Generate a hidden input with the request CSRF token
  #
  # This input is automatically generated when using
  # `Lucky::FormHelpers#form_for`. It creates a hidden input with the CSRF
  # token. THis ensures that the form is safe. If you try to submit a form
  # without a CSRF token it will fail with a 403 forbidden status code.
  def csrf_hidden_input : Nil
    input type: "hidden",
      name: ProtectFromForgery::PARAM_KEY,
      value: ProtectFromForgery.get_token(context)
  end

  # Meta tags used for submitting AJAX links and forms
  #
  # These tags are automatically added to MainLayout when generating a new
  # project. They are used by Rails UJS to safely submit forms and non-GET AJAX
  # requests
  def csrf_meta_tags : Nil
    meta name: "csrf-param",
      content: ProtectFromForgery::PARAM_KEY
    meta name: "csrf-token",
      content: ProtectFromForgery.get_token(context)
  end
end
