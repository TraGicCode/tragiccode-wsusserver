class wsusserver::built_in_computer_target_groups(
) {
  ['All Computers', 'Unassigned Computers'].each |$built_in_computer_target_group| {
    wsusserver_computer_target_group { $built_in_computer_target_group:
      ensure => 'present',
    }
  }
}
