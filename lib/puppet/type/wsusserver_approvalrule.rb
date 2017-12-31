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
      fail('A non-empty approval rule name must be specified.') if value.empty? || value.nil?
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
    defaultto :true
    # rubocop:disable Lint/BooleanSymbol
    newvalue(:true)
    newvalue(:false)
    # rubocop:enable Lint/BooleanSymbol
    munge do |value|
      PuppetX::Tragiccode::TypeHelpers.munge_boolean(value)
    end
  end
  # NOTE: If you set :array_matching to :all, EVERY value passed for that parameter/property will be cast to an array (which means if you pass a value of ‘foo’, 
  # you’ll get an array with a single element – the string of ‘foo’).
  #
  # NOTE: What do i display if no products exist?
  #       puppet user simply doesn't show the groups array if the user is in no groups
  #       puppet host simply doesn't show the host_aliases if the host entry has none
  # 
  # user { 'nobody':
  #   ensure   => 'present',
  #   comment  => 'Unprivileged User',
  #   gid      => -2,
  #   home     => '/var/empty',
  #   password => '*',
  #   shell    => '/usr/bin/false',
  #   uid      => -2,
  # }
  # user { 'root':
  #   ensure   => 'present',
  #   comment  => 'System Administrator',
  #   gid      => 0,
  #   groups   => ['admin', 'certusers', 'daemon', 'kmem', 'operator', 'procmod', 'procview', 'staff', 'sys', 'tty', 'wheel'],
  #   home     => '/var/root',
  #   password => '*',
  #   shell    => '/bin/sh',
  #   uid      => 0,
  # }
  newproperty(:products, :array_matching => :all) do
      desc 'Specifies the products in which this rule should apply to.'
      validate do |value|
        fail('Products for an approval rule must be a non-empty string.') if value.empty? || value.nil?
      end
  end

  # newproperty(:classifications, :array_matching => :all) do
  #     desc 'Specifies the classifications in which this rule should apply to.'
  # end

  # newproperty(:computer_groups, :array_matching => :all) do
  #     desc 'Specifies the computer groups in which this rule should apply to.'
  # end

  validate do
    fail('ensure is a required attribute') if self[:ensure].nil?
  end
end
