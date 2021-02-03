require "../spec_helper"

include ContextHelper

private class TestPage
  include Lucky::HTMLPage

  def render
  end

  def render_select(field)
    select_input field do
    end
    self
  end

  def render_options(field, options)
    options_for_select(field, options)
    self
  end

  def render_prompt(label)
    select_prompt(label)
    self
  end

  def html
    view
  end
end

class SomeFormWithCompany
  def company_id
    Avram::PermittedAttribute(Int32).new(
      name: :company_id,
      param: "1",
      value: nil,
      param_key: "company"
    )
  end
end

describe Lucky::SelectHelpers do
  it "renders select" do
    view.render_select(form.company_id).html.to_s.should eq <<-HTML
    <select name="company:company_id"></select>
    HTML
  end

  it "renders options" do
    view.render_options(form.company_id, [{"Volvo", 2}, {"BMW", 3}, {"None", nil}])
      .html.to_s.should eq <<-HTML
      <option value="2">Volvo</option><option value="3">BMW</option><option value="">None</option>
      HTML
  end

  it "renders selected option" do
    view.render_options(form.company_id, [{"Volvo", 1}, {"BMW", 3}])
      .html.to_s.should eq <<-HTML
      <option value="1" selected="true">Volvo</option><option value="3">BMW</option>
      HTML
  end

  it "renders a blank option as a prompt" do
    view.render_prompt("Which one do you want?").html.to_s.should eq <<-HTML
    <option value="">Which one do you want?</option>
    HTML
  end
end

private def view
  TestPage.new(build_context)
end

private def form
  SomeFormWithCompany.new
end
