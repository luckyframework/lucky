# :nodoc:
#
# Used to represent a gap in a pagination series
class Lucky::Paginator::Gap
  def ==(other : self) : Bool
    true # All gaps are equal to each other
  end
end
