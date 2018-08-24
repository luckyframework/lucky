class SignUps::New < Lucky::Action
  get "/sign-up" do
    text "Sign up form goes here"
  end
end

class Home::Index < Lucky::Action
  get "/" do
    render Lucky::WelcomePage
  end
end
