# Include this module in a type to allow it to be output in tags
#
# Lucky already includes this in a few common types like `Int` and `Bool`.
# Typically this is enough but if you have a type you want to allow in tags, you
# can do so.
#
# For example:
#
# ```
# class EmailAddress
#   include Lucky::AllowedInTags
#
#   def initialize(@value : String)
#   end
#
#   def to_s(io)
#     io.puts @value
#   end
# end
# ```
#
# Now an `EmailAddress` can be used for tag content without calling `to_s`:
#
# ```
# h1 EmailAddress.new("myemail.com")
# ```
module Lucky::AllowedInTags
end
