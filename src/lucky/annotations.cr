# Declares the expected type of one or more path params for an action.
#
# Add it above an action class and map each path variable to a type. Lucky
# generates a typed accessor for each declared param, and the router treats a
# segment that can't be parsed to the declared type as a non-match (404).
#
# ```
# @[Lucky::PathParam(id: UUID)]
# class Users::Show < BrowserAction
#   get "/users/:id" do
#     # `id` returns a `UUID`, not a `String`
#     plain_text "User #{id}"
#   end
# end
# ```
#
# Any type that `Lucky::ParamParser.parse` understands is supported: `String`,
# `Int16`, `Int32`, `Int64`, `Float64`, `Bool`, `UUID`, and `Time`. Custom
# types are supported by defining a matching `Lucky::ParamParser.parse`
# overload.
annotation Lucky::PathParam
end
