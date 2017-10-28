require "../spec_helper"

private class FakeAction
  include LuckyWeb::ContentTypeHelpers

  class_property content_type : String = ""
  class_property headers : HTTP::Headers = HTTP::Headers.new

  def content_type
    self.class.content_type
  end

  def headers
    self.class.headers
  end
end

describe LuckyWeb::ContentTypeHelpers do
  it "works for JSON" do
    set_content_type "application/json" do
      FakeAction.new.json?.should be_true
    end

    set_content_type "not/json" do
      FakeAction.new.json?.should be_false
    end
  end

  it "works for HTML" do
    set_content_type "text/html" do
      FakeAction.new.html?.should be_true
    end

    set_content_type "not/html" do
      FakeAction.new.html?.should be_false
    end
  end

  it "works for AJAX" do
    set_header "X-Requested-With", "XMLHttpRequest" do
      FakeAction.new.ajax?.should be_true
    end

    set_header "X-Requested-With", "not ajax" do
      FakeAction.new.ajax?.should be_false
    end
  end

  it "works for XML" do
    set_content_type "application/xml" do
      FakeAction.new.xml?.should be_true
    end

    set_content_type "not/xml" do
      FakeAction.new.xml?.should be_false
    end
  end
end

private def set_content_type(content_type)
  begin
    FakeAction.content_type = content_type
    yield
  ensure
    FakeAction.content_type = ""
  end
end

private def set_header(key, value)
  begin
    FakeAction.headers[key] = value
    yield
  ensure
    FakeAction.headers = HTTP::Headers.new
  end
end
