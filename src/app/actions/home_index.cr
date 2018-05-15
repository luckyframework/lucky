class SignIns::New < Lucky::Action
  get "/sign-in" do
    text "Sign in form goes here"
  end
end

class Home::Index < Lucky::Action
  get "/" do
    render Lucky::WelcomePage
  end
end
