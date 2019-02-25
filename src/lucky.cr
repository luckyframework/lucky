require "wordsmith"
require "avram"
require "exception_page"
require "habitat"
require "cry"
require "./lucky/quick_def"
require "./charms/*"
require "http/server"
require "lucky_router"
require "./lucky/support/*"
require "./lucky/errors"
require "./lucky/http_respondable"
require "./lucky/exceptions"
require "./lucky/response"
require "./lucky/cookies/*"
require "./lucky/*"

module Lucky
  Habitat.create do
    setting logger : Lucky::Logger
  end

  def self.logger
    settings.logger
  end
end
