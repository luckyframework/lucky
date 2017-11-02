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
      param: "company_id",
      value: "",
      form_name: "company"
    )
    LuckyRecord::AllowedField.new(field)
  end
end

describe LuckyWeb::SelectHelpers do
  it "renders select" do
    (view.select form.company_id do; end).to_s.should contain <<-HTML
      <select name="company:company_id"></select>
    HTML
  end

  it "renders select with options" do
    view.select form.company_id do
      options_for_select(form.company_id, [{"Volvo", 1}])
    end.to_s.should contain <<-HTML
      <select name="company:company_id">
        <option value="1">Volvo</option>
      </select>
    HTML
  end
end

private def view
  TestPage.new
end

private def form
  SomeFormWithCompany.new
end