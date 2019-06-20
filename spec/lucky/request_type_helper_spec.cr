require "../spec_helper"

private class FakeAction
  include Lucky::RequestTypeHelpers

  class_property headers : HTTP::Headers = HTTP::Headers.new

  def headers
    self.class.headers
  end
end

describe Lucky::RequestTypeHelpers do
  it "works for JSON" do
    set_header "Content-Type", "application/json" do
      FakeAction.new.json?.should be_true
    end

    set_header "Content-Type", "not/json" do
      FakeAction.new.json?.should be_false
    end
  end

  it "works for HTML" do
    set_header "Content-Type", "text/html" do
      FakeAction.new.html?.should be_true
    end

    set_header "Content-Type", "not/html" do
      FakeAction.new.html?.should be_false
    end

    set_header "Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" do
      FakeAction.new.html?.should be_true
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
    set_header "Content-Type", "application/xml" do
      FakeAction.new.xml?.should be_true
    end

    set_header "Content-Type", "application/xhtml+xml" do
      FakeAction.new.xml?.should be_true
    end

    set_header "Content-Type", "not/xml" do
      FakeAction.new.xml?.should be_false
    end
  end

  it "works for plain text" do
    set_header "Content-Type", "text/plain" do
      FakeAction.new.plain?.should be_true
    end

    set_header "Content-Type", "text/plain; charset=UTF8" do
      FakeAction.new.plain?.should be_true
    end
  end
end

private def set_header(key, value)
  FakeAction.headers[key] = value
  yield
ensure
  FakeAction.headers = HTTP::Headers.new
end
