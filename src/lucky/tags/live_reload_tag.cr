module Lucky::LiveReloadTag
  def live_reload_connect_tag(ms : Int32 = 1000) : Nil
    {% if flag?(:livereloadws) %}
      tag "script" do
        raw <<-JS
        (function() {
          var ws = new WebSocket("ws://#{Lucky::ServerSettings.host}:#{Lucky::ServerSettings.reload_port}");
          ws.onmessage = function() {
            setTimeout(function() {
              location.reload();
            }, #{ms});
          };
        })();
        JS
      end
    {% elsif flag?(:livereloadsse) %}
      tag "script" do
        raw <<-JS
        (function() {
          var stream = new EventSource("http://#{Lucky::ServerSettings.host}:#{Lucky::ServerSettings.reload_port}");
          stream.onmessage = function() {
            setTimeout(function() {
              location.reload();
            }, #{ms});
          };
        })();
        JS
      end
    {% end %}
  end
end
