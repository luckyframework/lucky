module Lucky::ParamHelpers
  memoize def params : Lucky::Params
    context.params
  end
end
