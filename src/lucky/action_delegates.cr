module Lucky::ActionDelegates
  macro included
    delegate flash, better_cookies, better_session, session, response, request, to: context
  end
end
