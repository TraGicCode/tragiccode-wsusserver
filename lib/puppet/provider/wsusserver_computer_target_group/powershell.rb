Puppet::Type.type(:wsusserver_computer_target_group).provide(:powershell) do
  commands powershell: 'powershell.exe'

  # Initializes property_hash
  def self.instances
    get_computer_target_groups = <<-EOF
(Get-WsusServer).GetComputerTargetGroups() | % {
  New-Object -TypeName PSObject -Property @{
      name = $PSItem.Name
      id   = $PSItem.Id
  }
} | ConvertTo-Json -Depth 10
  EOF
    output = powershell(get_computer_target_groups)
    json_parsed_output = JSON.parse(output)
    Puppet.debug("json parsed computer target groups are #{json_parsed_output}")
    json_parsed_output.map do |computer_target_group|
      computer_target_group_hash = {}
      computer_target_group_hash[:ensure] = :present
      computer_target_group_hash[:name]   = computer_target_group['name']
      computer_target_group_hash[:id]     = computer_target_group['id']
      new(
        computer_target_group_hash,
      )
    end
  end

  # Get all resource in catalog and associate them with
  # an instance this provider found on the target system
  def self.prefetch(resources)
    Puppet.debug('Prefetching computer_target_groups')
    computer_target_groups = instances
    resources.each do |name, resource|
      provider_instance = computer_target_groups.find { |computer_target_group| computer_target_group.name == resource[:name] }
      if provider_instance
        resources[name].provider = provider_instance
      end
    end
  end

  def exists?
    Puppet.debug("Checking if #{resource[:name]} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("Creating #{resource[:name]}")
    create_computer_target_group = <<-EOF
(Get-WsusServer).CreateComputerTargetGroup('#{resource[:name]}')
EOF
    powershell(create_computer_target_group)

    # Remember readonly properties are only ever shown on puppet resource query commands so this works fine!
    @property_hash = resource.to_hash
  end

  def destroy
    Puppet.debug("Deleting #{resource[:name]}")
    delete_computer_target_group = <<-EOF
$computer_target_group = (Get-WsusServer).GetComputerTargetGroup('#{@property_hash[:id]}')
$computer_target_group.Delete()
EOF
    powershell(delete_computer_target_group)
    @property_hash.clear
  end

  def id
    @property_hash[:id]
  end

  def read_only(_value)
    raise('This is a read-only property.')
  end

  alias_method :id=, :read_only
end
