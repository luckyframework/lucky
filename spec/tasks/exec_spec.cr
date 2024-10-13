require "../spec_helper"

describe Lucky::Exec do
  it "runs the editor" do
    with_test_template do
      Lucky::Exec.new.print_help_or_call(args: ["--once", "--editor", %(echo '5 + 5' >)])

      newest_code.should eq <<-CODE
      5 + 5

      CODE
    end
  end
end

private def with_test_template(&)
  Lucky::Exec.temp_config(template_path: Path["spec/support/exec_template.cr.template"].to_s) do
    yield
  end
end

private def newest_code
  Cry::Logs.new.newest.code
end
