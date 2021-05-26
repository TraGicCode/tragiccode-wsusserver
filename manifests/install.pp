# Class: wsusserver::install
#
#
class wsusserver::install(
  Enum['present', 'absent'] $package_ensure        = $wsusserver::params::package_ensure,
  Boolean $include_management_console              = $wsusserver::params::include_management_console,
  Stdlib::Absolutepath $wsus_directory             = $wsusserver::params::wsus_directory,
  Boolean $join_improvement_program                = $wsusserver::params::join_improvement_program,
) inherits wsusserver::params {

  windowsfeature { 'UpdateServices':
    ensure => $package_ensure,
    notify => Exec["post install wsus content directory ${wsus_directory}"],
  }

  $_management_console_ensure = $include_management_console ? {
    true    => 'present',
    default => 'absent',
  }
  windowsfeature { 'UpdateServices-UI':
    ensure  => $_management_console_ensure,
    require => Windowsfeature['UpdateServices'],
  }

  $join_improvement_program_flag = bool2num($join_improvement_program)
  exec { "post install wsus content directory ${wsus_directory}":
    command     => "if (!(Test-Path -Path \$env:TMP)) {
                      New-Item -Path \$env:TMP -ItemType Directory
                    }
                    & 'C:\\Program Files\\Update Services\\Tools\\WsusUtil.exe' PostInstall CONTENT_DIR=\"${wsus_directory}\" MU_ROLLUP=${join_improvement_program_flag}
                    if (\$LASTEXITCODE -eq 1) { 
                      Exit 1 
                    } 
                    else { 
                      Exit 0 
                    }",
    logoutput   => true,
    refreshonly => true,
    timeout     => 1200,
    provider    => 'powershell',
    require     => [Windowsfeature['UpdateServices'], Windowsfeature['UpdateServices-UI']]
  }
}
