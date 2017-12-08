Puppet::Type.type(:wsusserver_approvalrule).provide(:powershell) do
  commands powershell: 'powershell.exe'

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  # Initializes property_hash
  def self.instances
    get_approval_rules = <<-EOF
$approval_rules = @()
(Get-WsusServer).GetInstallApprovalRules() | % {

  $approval_rules += New-Object -TypeName PSObject -Property @{
    name    = $PSItem.Name
    enabled = $PSItem.Enabled
    rule_id = $PSItem.Id
  }
}
ConvertTo-Json -InputObject $approval_rules -Depth 10
EOF
    output = powershell(get_approval_rules)
    json_parsed_output = JSON.parse(output)
    Puppet.debug("json parsed approval rules are #{json_parsed_output}")
    json_parsed_output.map do |rule|
      new(
        ensure:  :present,
        name:    rule['name'],
        enabled: rule['enabled'].to_s,
        rule_id: rule['rule_id'],
      )
    end
  end

  # Get all resource in catalog and associate them with
  # an instance this provider found on the target system
  def self.prefetch(resources)
    Puppet.debug('Prefetching approval_rules')
    approval_rules = instances
    resources.each do |name, resource|
      provider_instance = approval_rules.find { |approval_rule| approval_rule.name == resource[:name] }
      if provider_instance
        Puppet.debug("Assigning #{resource[:name]}, #{resource[:enabled]}")
        resources[name].provider = provider
      end
    end
  end

  def exists?
    Puppet.debug("Checking if #{resource[:name]} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("Creating #{resource[:name]}")
    create_approval_rule = <<-EOF
$approval_rule = (Get-WsusServer).CreateInstallApprovalRule('#{resource[:name]}')
$approval_rule.Enabled = $#{resource[:enabled]}
$approval_rule.Save()
EOF
    powershell(create_approval_rule)
  end

  def destroy
    Puppet.debug("Deleting #{resource[:name]}")
    delete_approval_rule = <<-EOF
$wsus_server = Get-WsusServer
$approval_rule = $wsus_server.GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{resource[:name]}' }
$wsus_server.DeleteInstallApprovalRule($approval_rule.Id)
EOF
    powershell(delete_approval_rule)
  end

  def enabled
    @property_hash[:enabled]
  end

  def enabled=(value)
    @property_flush[:enabled] = value
  end

  def rule_id
    @property_hash[:rule_id]
  end

  def read_only(_value)
    raise('This is a read-only property.')
  end

  alias_method :rule_id=, :read_only

  def should_flush_properties?
    !@property_flush.empty?
  end

  def flush
    Puppet.debug("Flushing #{resource[:name]}")
    if should_flush_properties?
      flush_approval_rule = "$approval_rule = (Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{resource[:name]}' }"
      flush_approval_rule << "\n$approval_rule.Enabled = $#{@property_flush[:enabled]}" if @property_flush[:enabled]
      flush_approval_rule << "\n$approval_rule.Save()"
      powershell(flush_approval_rule)
    end

    # Remember readonly properties are only ever shown on puppet resource query commands so this works fine!
    @property_hash = resource.to_hash
  end
end
