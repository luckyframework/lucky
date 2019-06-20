require "wordsmith"
require "avram"
require "exception_page"
require "habitat"
require "cry"
require "dexter"
require "mime"
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
require "./lucky/secure_headers/*"
require "./lucky/route_helper"
require "./lucky/*"

module Lucky
  Habitat.create do
    setting logger : Dexter::Logger
  end

  def self.logger
    settings.logger
  end
end
