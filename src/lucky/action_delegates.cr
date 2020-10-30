# :nodoc:
module Lucky::ActionDelegates
  macro included
    delegate flash, cookies, session, response, request, to: context
  end
end
