Puppet::Type.newtype(:wsusserver_computer_target_group) do
  @doc = 'Creates computer target groups for wsusserver.'

  newproperty(:ensure, parent: Puppet::Property::Ensure) do
    desc 'Specifies whether the computer target group should be present or absent.'
    defaultto :present

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, namevar: true) do
    desc 'The name of the computer target group.'
    validate do |value|
      raise('A non-empty computer target group name must be specified.') if value.empty? || value.nil?
      raise('The computer target group name cannot contain any of the characters certain special characeters.') if value !~ %r{^[^~!@#$%^&*()=+\[\]{}\\|;:\'"<>\/]+$}
    end
  end

  newproperty(:id) do
    desc 'The auto-generated id of the computer target group. This property is read-only.'
  end
end
