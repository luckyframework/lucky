module Lucky::ActionDelegates
  macro included
    delegate flash, better_cookies, session, response, request, to: context
  end
end
