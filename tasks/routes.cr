require "colorize"

class Routes < LuckyCli::Task
  banner "All the routes for the app"

  def call
    LuckyWeb::Router.routes.each do |route|
      puts "#{route[:method].to_s.upcase} #{route[:path].colorize(:green)} #{route[:action].colorize(:cyan)}"
    end
  end
end
