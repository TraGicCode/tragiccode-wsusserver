# Module Specific Puppet Extensions
module PuppetX::Tragiccode
end

# Class for dealing with munging
class PuppetX::Tragiccode::TypeHelpers
  def self.munge_boolean(value)
    case value
    # rubocop:disable Lint/BooleanSymbol
    when true, 'true', :true
      :true
    when false, 'false', :false
      :false
    # rubocop:enable Lint/BooleanSymbol
    else
      raise('munge_boolean only takes booleans')
    end
  end

  def self.munge_integer(value)
    value.is_a?(Array) ? value.map { |v| v.to_i } : value.to_i
  end
end
