require "../spec_helper"

private class FakeAction
  include Lucky::RequestTypeHelpers
  default_format :my_default_format

  property context : HTTP::Server::Context = ContextHelper.build_context
  class_property _accepted_formats = [] of Symbol

  delegate request, to: context
end

describe Lucky::RequestTypeHelpers do
  it "determines the format from 'Accept' header correctly" do
    Lucky::MimeType.accept_header_formats.each do |header, format|
      override_accept_header header.to_s do |action|
        action.accepts?(format).should be_true
      end
    end
  end

  it "uses the default if no header is set" do
    override_accept_header "" do |action|
      action.accepts?(:my_default_format).should be_true
    end
  end

  it "doesn't use the default if header is given" do
    override_accept_header "application/json" do |action|
      action.accepts?(:my_default_format).should be_false
    end
  end

  it "raises if the format is unknown" do
    expect_raises Lucky::UnknownAcceptHeaderError do
      override_accept_header "wut" do |action|
        action.accepts?(:blow_up)
      end
    end
  end

  it "checks if client accepts JSON" do
    override_format :json, &.json?.should(be_true)
    override_format :foo, &.json?.should(be_false)
  end

  it "checks if client accepts HTML" do
    override_format :html, &.html?.should(be_true)
    override_format :foo, &.html?.should(be_false)
  end

  it "checks if client accepts XML" do
    override_format :xml, &.xml?.should(be_true)
    override_format :foo, &.xml?.should(be_false)
  end

  it "checks if client accepts plain text" do
    override_format :plain_text, &.plain_text?.should(be_true)
    override_format :foo, &.plain_text?.should(be_false)
  end

  it "checks if request send via AJAX" do
    action = FakeAction.new
    action.context._clients_desired_format = :ajax
    action.ajax?.should(be_false)

    action.context.request.headers["X-Requested-With"] = "XMLHttpRequest"
    action.ajax?.should(be_true)
  end

  it "checks if request is multipart" do
    action = FakeAction.new
    action.multipart?.should(be_false)

    action.context.request.headers["Content-Type"] = "multipart/form-data; boundary="
    action.multipart?.should(be_true)
  end
end

private def override_format(format : Symbol?)
  action = FakeAction.new
  action.context._clients_desired_format = format
  yield action
end

private def override_accept_header(accept_header : String)
  action = FakeAction.new
  action.context.request.headers["accept"] = accept_header
  yield action
end
