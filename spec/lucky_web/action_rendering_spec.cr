require "../../spec_helper"

class Rendering::IndexPage < LuckyWeb::HTMLView
  assign title : String

  def render
    text title
  end
end

class Rendering::Index < LuckyWeb::Action
  action do
    render title: "Anything"
  end
end

describe LuckyWeb::Action do
  describe "rendering" do
    it "render assigns" do
      body = Rendering::Index.new(context, params).call.body

      body.should eq "Anything"
    end
  end
end

private def context(path = "/")
  io = IO::Memory.new
  request = HTTP::Request.new("GET", path)
  response = HTTP::Server::Response.new(io)
  HTTP::Server::Context.new request, response
end

private def params
  {} of String => String
end
