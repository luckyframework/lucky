require "../../spec_helper"

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

  def html
    @view
  end
end

class SomeFormWithCompany
  def company_id
    field = LuckyRecord::Field(String).new(
      name: :company_id,
      param: "1",
      value: "",
      form_name: "company"
    )
    LuckyRecord::AllowedField.new(field)
  end
end

describe Lucky::SelectHelpers do
  it "renders select" do
    view.render_select(form.company_id).html.to_s.should eq <<-HTML
    <select name="company:company_id"></select>
    HTML
  end

  it "renders options" do
    view.render_options(form.company_id, [{"Volvo", 2}, {"BMW", 3}])
      .html.to_s.should eq <<-HTML
    <option value="2">Volvo</option><option value="3">BMW</option>
    HTML
  end

  it "renders selected option" do
    view.render_options(form.company_id, [{"Volvo", 1}, {"BMW", 3}])
      .html.to_s.should eq <<-HTML
    <option value="1" selected="true">Volvo</option><option value="3">BMW</option>
    HTML
  end
end

private def view
  TestPage.new
end

private def form
  SomeFormWithCompany.new
end
