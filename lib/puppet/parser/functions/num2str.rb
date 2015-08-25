#
# num2str.rb
#

module Puppet::Parser::Functions
  newfunction(:num2str, :type => :rvalue, :doc => <<-EOS
This function converts a number into a string representation of a number.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "num2str(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1

    number = arguments[0]

    begin
      number = number.to_s
    rescue ArgumentError => ex
      raise(Puppet::ParseError, "num2str(): Unable to parse argument: #{ex.message}")
    end

    return number
  end
end

# vim: set ts=2 sw=2 et :
