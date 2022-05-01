class HTTP::Request
  # This is an alternative to `remote_address`
  # since that casts to `Socket::Address`, and not all
  # subclasses have an `address` method to give you the value.
  # ```
  # request.remote_address.as?(Socket::IPAddress).try(&.address)
  # ```
  property remote_ip : String = ""
end
