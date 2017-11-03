require "../../spec_helper"

private class TestPage
  include LuckyWeb::Page

  render do
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

describe LuckyWeb::SelectHelpers do
  it "renders select" do
    (view.select_input form.company_id do; end).to_s.should contain <<-HTML
    <select name="company:company_id"></select>
    HTML
  end

  it "renders option" do
    (view.options_for_select form.company_id, [{"Volvo", 2}]).to_s.should contain <<-HTML
    <option value="2" selected="false">Volvo</option>
    HTML
  end

  it "renders selected option" do
    (view.options_for_select form.company_id, [{"Volvo", 1}]).to_s.should contain <<-HTML
    <option value="1" selected="true">Volvo</option>
    HTML
  end
end

private def view
  TestPage.new
end

private def form
  SomeFormWithCompany.new
end
