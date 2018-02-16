require "../error_action"
require "../html_page"

class Lucky::DebugAction
  include Lucky::Renderable
  include Lucky::Exposeable

  def initialize(@context : HTTP::Server::Context)
  end

  def perform_action(error : Exception, status : Int32)
    response = handle_error(error, status)
    response.print
  end

  def handle_error(error : Exception, status : Int32)
    error.inspect_with_backtrace(STDERR)
    render_error_page status: status, error: error
  end

  private def render_error_page(status : Int32, error : Exception)
    context = @context
    render DebugPage, status: status, error: error
  end

  class DebugPage
    include Lucky::HTMLPage
    needs status : Int32
    needs error : Exception

    def render
      html_doctype

      html lang: "en" do
        head do
          utf8_charset
          title "Debug Error Page"
          responsive_meta_tag
          error_page_styles
        end

        body do
          content(@error, @status)
          error_page_javascript
        end
      end
    end

    def error_page_styles
      style <<-CSS
      body {
        background-color: #F4F7F6;
        color: #333;
        font-family: sans-serif;
      }

      h1{
        color: red;
      }

      ul li.app{

      }

      ul li.external{
        color: #888;
      }

      @media only screen and (max-width: 500px) {
        .status-code {
          font-size: 18px;
        }

        .title {
          font-size: 26px;
          line-height: 40px;
          margin: 20px 0 35px 0;
        }
      }
    CSS
    end

    def error_page_javascript
      script do
        raw <<-JS
          (function(){
            function setupClickListeners(){
              document.querySelector('.application-trace').onclick = function(){
                hideAllLines();
                showLinesWithClasses(['app']);
              }
              document.querySelector('.framework-trace').onclick = function(){
                hideAllLines();
                showLinesWithClasses(['app', 'framework']);
              }
              document.querySelector('.full-trace').onclick = function(){
                hideAllLines();
                showLinesWithClasses(['app', 'framework', 'external']);
              }
            }
            function hideAllLines(){
              var allLines = document.querySelectorAll('.backtrace li');
              for(var i =0; i < allLines.length; i++) {
                allLines[i].style.display = "none";
              }
            }
            function showLinesWithClasses(cssClasses){
              for(var i =0; i < cssClasses.length; i++){
                var specificLines = document.querySelectorAll('.backtrace li.' + cssClasses[i]);
                for(var j =0; j < specificLines.length; j++) {
                  specificLines[j].style.display = "block";
                }
              }
            }
            setupClickListeners();
            hideAllLines();
            showLinesWithClasses(['app']);
          }())
        JS
      end
    end

    def content(error, status)
      h1 "#{status} #{error.class.to_s}: #{error.message}"
      pre do
        error_output(error)
      end
    end

    def error_output(error)
      backtrace = error.inspect_with_backtrace
      lines = backtrace.split("\n")
      # First line is the message again
      lines.shift
      a "Application Trace", href: "#", class: "application-trace"
      text " | "
      a "Framework Trace", href: "#", class: "framework-trace"
      text " | "
      a "Full Trace", href: "#", class: "full-trace"
      ul class: "backtrace" do
        lines.each do |line|
          line = line.gsub(/^\s*from\s+/, "")
          css_class = nil
          if line =~ /^src\//
            css_class = "app"
          elsif line =~ /^lib\/lucky\//
            css_class = "framework"
          else
            css_class = "external"
          end
          li line, class: css_class
        end
      end
    end
  end
end
