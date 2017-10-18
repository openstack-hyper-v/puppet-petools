# Class: petools::adk
#
# This retrieves the adk for winows and installs it
# It also generates the winpe image and pxeboot files
#



class petools::adk(){

 include petools::commands


  Exec{
#      path => "${powershell_path};${dism_path};${bcd_path};${wsim_path};${::path}",
    path => "${::dism_path};${::bcd_path};${::wsim_path};${::path}",
    logoutput => true,
  }



  file { 'pe_dir':
    ensure => directory,
    path   => $petools::pe_dir,
  }

  file { 'pe_src':
    ensure => directory,
    path   => $petools::pe_src,
  }
  file { 'pe_drivers':
    ensure => directory,
    path   => $petools::pe_drivers,
  }

  file { 'pe_logs':
    ensure => directory,
    path   => $petools::pe_logs,
  }

  file { 'pe_bin':
    ensure => directory,
    path   => $petools::pe_bin,
  }
  file { 'pe_build':
    ensure => directory,
    path   => $petools::pe_build,
  }
  file { 'pe_mount':
    ensure => directory,
    path   => $petools::pe_mount,
  }
  file { 'pe_tmp':
    ensure => directory,
    path   => $petools::pe_tmp,
  }

  file { 'pe_iso':
    ensure => directory,
    path   => $petools::pe_iso,
  }
  #  writing directly to mount on q
  #
  file { 'pe_pxe':
    ensure => directory,
    path   => $petools::pe_pxe,
    mode   => '0770',
    owner  => 'Administrator',
    group  => 'Administrators',
  }

  file { "${petools::pe_pxe}\\Boot":
    ensure => directory,
    mode   => '0770',
    owner  => 'Administrator',
    group  => 'Administrators',
  }

  file { "${petools::pe_build}\\media":
    ensure  => directory,
    recurse => true,
    source  => "${petools::pe_root}\\amd64\\media",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [File['pe_build'],Exec['install_adk']],
  }

  file { "${petools::pe_build}\\winpe.wim":
    ensure  => file,
    source  => "${petools::pe_root}\\amd64\\en-us\\winpe.wim",
    mode    => '0777',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [File['pe_build'],Exec['install_adk']],
  }
  file { "${petools::pe_build}\\etfsboot.com":
    ensure  => file,
    source  => "${petools::pe_deployment_tools}\\amd64\\Oscdimg\\etfsboot.com",
    mode    => '0777',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [File['pe_build'],Exec['install_adk']],
  }
  file { "${petools::pe_build}\\oscdimg.exe":
    ensure  => file,
    source  => "${petools::pe_deployment_tools}\\amd64\\Oscdimg\\oscdimg.exe",
    mode    => '0777',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [File['pe_build'],Exec['install_adk']],
  }
class{'staging':
  path    => 'C:/programdata/staging',
  owner   => 'Administrator',
  group   => 'Administrator',
  mode    => '0777',
  require => Package['unzip'],
}

acl{'c:\ProgramData\staging':
  permissions => [
    { identity => 'Administrator', rights => ['full'] },
	{ identity => 'mediacenter', rights => ['full'] },
	{ identity => 'Administrators', rights => ['full'] },
  ],
  require     => Class['staging'],
}

#  exec {'get_adk':
#    path    => $::path,
#    command => "${system32}\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy remotesigned -Command Invoke-WebRequest -UseBasicParsing -uri ${petools::adk_url} -OutFile ${petools::adk_file}",
#    creates => "${petools::pe_src}\${petools::adk_file}",
#    cwd     => $petools::pe_src,
#    require => File['pe_src']
#  }
  staging::file{"${petools::adk_file}":
    source => "${petools::adk_url}",
  }
  notice("Silently Installing ${petools::adk_file} from ${petools::pe_src} into destination ${petools::pe_programs}")
  exec { 'install_adk':
    command => "c:\\programdata\\staging\\petools\\adksetup.exe /quiet /norestart /features ${petools::adk_features} /log ${petools::adk_install_log}",
    require => [
      File['pe_src'],
      Staging::File["${petools::adk_file}"],
    ],
    notify  => Exec['unmount_q'],
    timeout => 0,
  }
  exec { 'set_pe_cmd_env':
    command     => 'cmd.exe /c "C:\\Program Files (x86)\\Windows Kits\\8.0\\Assessment and Deployment Kit\\Deployment Tools\\DandISetEnv.bat"',
    path        => $::path,
    require     => [File['pe_build'],Exec['install_adk']],
    refreshonly => true,
  }
  exec { 'mount_pe':
    command => "cmd.exe /c dism.exe /Mount-Wim /WimFile:${petools::pe_build}\\winpe.wim /index:1 /MountDir:${petools::pe_mount}",
    path    => $::path,
    require => [File['pe_build'],Exec['install_adk']],
  }
  exec { 'unmount_pe':
    command     => "cmd.exe /c dism.exe /Unmount-Wim /WimFile:${petools::pe_build}\\winpe.wim /MountDir:${petools::pe_mount} /discard",
    refreshonly => true,
    require     => [Exec['mount_pe'],Exec['install_adk']],
  }

  exec { 'commit_pe':
    command     => "cmd.exe /c dism.exe /Unmount-Wim /MountDir:${petools::pe_mount} /commit",
    refreshonly => true,
    require     => [Exec['mount_pe'],Exec['create_bcd']],
  }
  file {"${petools::pe_pxe}\\Boot\\pxeboot.com":
    ensure  => file,
    source  => "${petools::pe_mount}\\Windows\\Boot\\PXE\\pxeboot.com",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [Exec['mount_pe'],File["${petools::pe_pxe}\\Boot"]],
  }
  file {"${petools::pe_pxe}\\Boot\\pxeboot.0":
    ensure  => file,
    source  => "${petools::pe_mount}\\Windows\\Boot\\PXE\\pxeboot.n12",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [Exec['mount_pe'],File["${petools::pe_pxe}\\Boot\\pxeboot.com"]],
  }
  file {"${petools::pe_pxe}\\Boot\\bootmgr.exe":
    ensure  => file,
    source  => "${petools::pe_mount}\\Windows\\Boot\\PXE\\bootmgr.exe",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [Exec['mount_pe'],File["${petools::pe_pxe}\\Boot\\pxeboot.0"]],
  }
  file {"${petools::pe_pxe}\\Boot\\abortpxe.com":
    ensure  => file,
    source  => "${petools::pe_mount}\\Windows\\Boot\\PXE\\abortpxe.com",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [Exec['mount_pe'],File["${petools::pe_pxe}\\Boot\\bootmgr.exe"]],
  }
  file {"${petools::pe_pxe}\\Boot\\boot.sdi":
    ensure  => file,
    source  => "${petools::pe_build}\\media\\Boot\\boot.sdi",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [Exec['mount_pe'],File["${petools::pe_build}\\media","${petools::pe_pxe}\\Boot\\abortpxe.com"]],
    before  => Exec['create_bcd'],
  }



  exec {'install_winpe_wmi':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_wmi}",
    require => Exec['mount_pe','install_adk'],
  } -> 

  exec {'install_winpe_wmi_en-us':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_wmi_enus}",
  } ->

  exec {'install_winpe_hta':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_hta}",
  } ->

  exec {'install_winpe_hta_en-us':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_hta_enus}",
  } -> 

  exec {'install_winpe_scripting':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_scripting}",
  } -> 
  exec {'install_winpe_netfx4':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_netfx4}",
  } -> 
  exec {'install_winpe_netfx4_en-us':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_netfx4_enus}",
  } ->
  exec {'install_winpe_powershell3':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_powershell3}",
  } ->
  exec {'install_winpe_powershell3_en-us':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_powershell3_enus}",
  } ->
  exec {'install_winpe_storagewmi':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_storagewmi}",
  } ->
  exec {'install_winpe_storagewmi_en-us':
    command => "dism.exe /image:${petools::pe_mount} /Add-Package /PackagePath:${petools::winpe_storagewmi_enus}",
  } ->

#  class {'petools::dell_drivers':}
#  class {'petools::kvm_drivers':}

## Removing installation of device drivers temporarily
#  exec {'install_device_drivers':
#    command => "dism.exe /image:${petools::pe_mount} /Add-Driver /driver:${petools::pe_drivers} /recurse /forceunsigned",
#    require => Exec['mount_pe','7z_extract_zip','7z_extract_iso','install_winpe_storagewmi_en-us'],
#    require => [
#      Exec['mount_pe','install_winpe_storagewmi_en-us'],
#      Class['petools::dell_drivers','petools::kvm_drivers'],
#    ]
#  }
  file {"${petools::pe_bin}\\bcdcreate.cmd":
    ensure  => file,
    source  => 'puppet:///modules/petools/edit_bcd_for_pxe.cmd',
    require => File['pe_bin'],
  }

  exec {'create_bcd':
    command => "cmd.exe /c ${petools::pe_bin}\\bcdcreate.cmd",
    cwd     => "${petools::pe_pxe}\\Boot",
    creates => "${petools::pe_pxe}\\Boot\\BCD",
    require => [
   #   Exec['install_device_drivers'],
      File['pe_bin',"${petools::pe_pxe}\\Boot\\boot.sdi"]
    ],
    notify  => Exec['commit_pe'],
  }

  file { 'winpe_image_final':
    ensure  => file,
    path    => "${petools::pe_pxe}\\Boot\\winpe.wim",
    source  => "${petools::pe_build}\\winpe.wim",
    require => Exec['commit_pe'],
    notify  => Exec['copy_pe_pxe_to_q'],
  }
  #  exec {'copy_pe_pxe_to_q':
  #  command     => "cmd.exe /c xcopy.exe ${pe_pxe}\\Boot ${drive_letter}:\\",
  #  cwd         => 'q:\\',
  #  require     => [File['winpe_image_final'],Exec['mount_petools']],
  #  refreshonly => true,
  #}
}
