module Lucky::ActionDelegates
  macro included
    delegate flash, session, response, request, to: context
  end
end
