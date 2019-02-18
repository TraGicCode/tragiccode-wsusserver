#
# example config for wsusserver
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
  #products                                  => [ '*' ], # all products
  products                                  => [ 'Windows Server 2012 R2', 'Windows Server 2016', 'Windows Server 2019' ],
  product_families                          => ['SQL Server', 'Developer Tools, Runtimes, and Redistributables'],
  update_classifications                    => [ 'Critical Updates', 'Security Updates', 'Updates'],
}
