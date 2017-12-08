require_relative '../../puppet_x/tragiccode/wsusserver_type_helpers'

Puppet::Type.newtype(:wsusserver_approvalrule) do
  @doc = 'Creates an automatic approval rule for wsusserver.'

  newproperty(:ensure, parent: Puppet::Property::Ensure) do
    desc 'Specifies whether the approval rule should be present or absent.'

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, namevar: true) do
    desc 'The name of the approval rule.'
    validate do |value|
      fail('A non-empty approval rule must be specified.') if value.empty? || value.nil?
      fail('The approval rule name cannot contain any of the characters certain special characeters.') if value !~ %r{^[^~!@#$%^&*()=+\[\]{}\\|;:\'"<>\/]+$}
    end
  end

  newproperty(:rule_id) do
    desc 'The auto-generated id of the approval rule. This property is read-only.'
    munge do |value|
      PuppetX::Tragiccode::TypeHelpers.munge_integer(value)
    end
  end

  newproperty(:enabled) do
    desc 'Specifies whether the rule is enabled or disabled.'
    # rubocop:disable Lint/BooleanSymbol
    newvalue(:true)
    newvalue(:false)
    # rubocop:enable Lint/BooleanSymbol
    munge do |value|
      PuppetX::Tragiccode::TypeHelpers.munge_boolean(value)
    end
  end

  # newproperty(:classifications, :array_matching => :all) do
  #     desc 'Specifies the classifications in which this rule should apply to.'
  # end

  # newproperty(:products, :array_matching => :all) do
  #     desc 'Specifies the products in which this rule should apply to.'
  # end

  # newproperty(:computer_groups, :array_matching => :all) do
  #     desc 'Specifies the computer groups in which this rule should apply to.'
  # end
end
