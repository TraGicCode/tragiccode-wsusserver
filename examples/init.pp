# The baseline for module testing used by Puppet Inc. is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# https://docs.puppet.com/guides/tests_smoke.html
#
class { 'wsusserver':
  package_ensure                            => 'present',
  include_management_console                => true,
  service_manage                            => true,
  service_ensure                            => 'running',
  service_enable                            => true,
  wsus_directory                            => 'C:\\WSUS',
  join_improvement_program                  => false,
  sync_from_microsoft_update                => true,
  update_languages                          => ['en'],
  targeting_mode                            => 'Client',
  host_binaries_on_microsoft_update         => false,
  synchronize_automatically                 => true,
  synchronize_time_of_day                   => '03:00:00', # this is in UTC, 24H Clock
  number_of_synchronizations_per_day        => 1,
  trigger_full_synchronization_post_install => false,
  #products                                  => [ '*' ],
  products                                  => [ 'Windows Server 2008',
                                              'Windows Server 2008 R2',
                                              'Windows Server 2012',
                                              'Windows Server 2012 R2',
                                              'Windows Server 2016',
                                              'Windows Server 2019' ],
  product_families                          => ['SQL Server','Developer Tools, Runtimes, and Redistributables'],
  update_classifications                    => [ 'Critical Updates', 'Security Updates', 'Updates'],
}
