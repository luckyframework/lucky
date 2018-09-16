module Lucky::ActionDelegates
  macro included
    delegate flash, cookies, session, session, response, request, to: context
  end
end
