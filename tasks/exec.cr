require "cry"
require "habitat"
require "lucky_cli"

class Lucky::Exec < LuckyCli::Task
  name "exec"
  summary "Execute code. Use this in place of a console/REPL"
  arg :editor, "Which editor to use", shortcut: "-e", optional: true
  arg :back, "Load code from this many sessions back. Default is 1.",
    shortcut: "-b",
    optional: true,
    format: /^\d+/
  switch :once, "Don't loop. Only run once.", shortcut: "-o"

  Habitat.create do
    setting editor : String = "vim"
    setting template_path : String = "#{__DIR__}/exec_template.cr.template"
  end

  def call
    editor_to_use = editor || settings.editor
    repeat = !once?
    sessions_back = (back || 1).to_i

    Cry::CodeRunner.new(
      code: "",
      editor: editor_to_use,
      repeat: repeat,
      back: sessions_back,
      template: settings.template_path
    ).run
  end
end
