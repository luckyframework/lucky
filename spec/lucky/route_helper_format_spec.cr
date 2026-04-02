require "../spec_helper"

include ContextHelper

class FormatBlog::Index < TestAction
  accepted_formats [:html, :rss], default: :html

  get "/format_blog" do
    plain_text "blog"
  end
end

class FormatBlog::Post::Show < TestAction
  accepted_formats [:html, :rss, :json], default: :html

  get "/format_blog/posts/:id" do
    plain_text "post"
  end
end

describe "Route helper format" do
  describe "Lucky::RouteHelper.resolve_extension" do
    it "resolves known format symbols" do
      Lucky::RouteHelper.resolve_extension(:rss).should eq("rss")
      Lucky::RouteHelper.resolve_extension(:json).should eq("json")
      Lucky::RouteHelper.resolve_extension(:html).should eq("html")
    end

    it "resolves plain_text to txt" do
      Lucky::RouteHelper.resolve_extension(:plain_text).should eq("txt")
    end
  end

  describe "Lucky::RouteHelper.insert_extension" do
    it "appends the extension to the path" do
      Lucky::RouteHelper.insert_extension("/blog", "rss").should eq("/blog.rss")
    end

    it "inserts the extension before query params" do
      Lucky::RouteHelper.insert_extension("/blog?page=1", "rss").should eq("/blog.rss?page=1")
    end

    it "inserts the extension before anchors" do
      Lucky::RouteHelper.insert_extension("/blog#top", "rss").should eq("/blog.rss#top")
    end

    it "returns the path unchanged for empty extensions" do
      Lucky::RouteHelper.insert_extension("/blog", "").should eq("/blog")
    end
  end

  describe ".as_*" do
    it "generates a path with the format extension" do
      FormatBlog::Index.as_rss.path.should eq("/format_blog.rss")
    end

    it "generates a url with the format extension" do
      FormatBlog::Index.as_rss.url.should eq("luckyframework.org/format_blog.rss")
    end
  end

  describe ".as_*.with()" do
    it "appends the format after path params" do
      FormatBlog::Post::Show.as_rss.with(id: 123).path.should eq("/format_blog/posts/123.rss")
    end

    it "works with different formats" do
      FormatBlog::Post::Show.as_json.with(id: 456).path.should eq("/format_blog/posts/456.json")
    end
  end

  describe ".with().as_*" do
    it "appends the format after path params" do
      FormatBlog::Post::Show.with(id: 123).as_rss.path.should eq("/format_blog/posts/123.rss")
    end
  end
end
