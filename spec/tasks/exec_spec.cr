require "../../spec_helper"

describe Lucky::Exec do
  it "runs the editor" do
    with_test_template do
      Lucky::Exec.new.call(["-e", %(echo 'puts 555' >)])

      newest_code.should eq <<-CODE
      puts 555

      CODE
    end
  end
end

private def with_test_template
  Lucky::Exec.temp_config(template_path: "spec/support/exec_template.cr.template") do
    yield
  end
end

private def newest_code
  Cry::Logs.new.newest.code
end
