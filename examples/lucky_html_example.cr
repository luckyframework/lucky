# Example: Using LuckyHtml module independently
# This demonstrates how LuckyHtml can be used as a standalone module

require "../src/lucky_html"

# Create a page using LuckyHtml modules
class WelcomePage
  include LuckyHtml::HTMLPage
  
  def render
    html do
      head do
        title "LuckyHtml Example"
        css_link "/assets/app.css"
      end
      
      body do
        h1 "Welcome to LuckyHtml!"
        
        div class: "content" do
          para "LuckyHtml provides type-safe HTML generation for Crystal applications."
          
          ul do
            li "Type-safe HTML DSL"
            li "Component-based architecture"  
            li "Built-in form helpers"
            li "CSRF protection"
          end
        end
        
        mount ExampleComponent, message: "Hello from a component!"
      end
    end
  end
end

# Create a reusable component
class ExampleComponent < LuckyHtml::BaseComponent
  needs message : String
  
  def render
    div class: "component" do
      h2 "Component Example"
      para message
      
      button "Click me", data_action: "click->example#handleClick"
    end
  end
end

# Usage example
require "http/server"

context = HTTP::Server::Context.new(
  HTTP::Request.new("GET", "/"),
  HTTP::Server::Response.new(IO::Memory.new)
)

page = WelcomePage.new(context: context)
html_output = page.perform_render

puts "Generated HTML:"
puts html_output