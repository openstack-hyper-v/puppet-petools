# Class: petools::adk
#
# This retrieves the adk for winows and installs it
# It also generates the winpe image and pxeboot files
#



class petools::adk(){

  import 'commands'


  Exec{
#      path => "${powershell_path};${dism_path};${bcd_path};${wsim_path};${::path}",
      path => "${::dism_path};${::bcd_path};${::wsim_path};${::path}",
  }

  file { 'pe_dir':
    ensure => directory,
    path   => $quartermaster::pe_dir,
  }

  file { 'pe_src':
    ensure => directory,
    path   => $quartermaster::pe_src,
  }
  file { 'pe_drivers':
    ensure => directory,
    path   => $quartermaster::pe_drivers,
  }

  file { 'pe_logs':
    ensure => directory,
    path   => $quartermaster::pe_logs,
  }

  file { 'pe_bin':
    ensure => directory,
    path   => $quartermaster::pe_bin,
  }
  file { 'pe_build':
    ensure => directory,
    path   => $quartermaster::pe_build,
  }
  file { 'pe_mount':
    ensure => directory,
    path   => $quartermaster::pe_mount,
  }
  file { 'pe_tmp':
    ensure => directory,
    path   => $quartermaster::pe_tmp,
  }

  file { 'pe_iso':
    ensure => directory,
    path   => $quartermaster::pe_iso,
  }
  #  writing directly to mount on q
  #
  file { 'pe_pxe':
    ensure => directory,
    path   => $quartermaster::pe_pxe,
    mode   => '0770',
    owner  => 'Administrator',
    group  => 'Administrators',
  }

  file { "${pe_pxe}\\Boot":
    ensure => directory,
    mode   => '0770',
    owner  => 'Administrator',
    group  => 'Administrators',
  }

  file { "${pe_build}\\media":
    ensure  => directory,
    recurse => true,
    source  => "${pe_root}\\amd64\\media",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [File['pe_build'],Exec['install_adk']],
  }

  file { "${pe_build}\\winpe.wim":
    ensure  => file,
    source  => "${pe_root}\\amd64\\en-us\\winpe.wim",
    mode    => '0777',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [File['pe_build'],Exec['install_adk']],
  }
  file { "${pe_build}\\etfsboot.com":
    ensure  => file,
    source  => "${pe_deployment_tools}\\amd64\\Oscdimg\\etfsboot.com",
    mode    => '0777',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [File['pe_build'],Exec['install_adk']],
  }
  file { "${pe_build}\\oscdimg.exe":
    ensure  => file,
    source  => "${pe_deployment_tools}\\amd64\\Oscdimg\\oscdimg.exe",
    mode    => '0777',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [File['pe_build'],Exec['install_adk']],
  }

  exec {'get_adk':
    path    => $::path,
    command => "c:\\Windows\\sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy remotesigned -Command Invoke-WebRequest -UseBasicParsing -uri ${adk_url} -OutFile ${adk_file}",
    creates => "${pe_src}\${file}",
    cwd     => $quartermaster::pe_src,
    require => File['pe_src']
  }


  notify {"Silently Installing ${adk_file} from ${pe_src} into destination ${pe_programs}":}

  exec { 'install_adk':
    command => "${pe_src}\\adksetup.exe /quiet /norestart /features ${adk_features} /log ${adk_install_log}",
    require => [File['pe_src'],Exec['get_adk']],
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
    command => "cmd.exe /c dism.exe /Mount-Wim /WimFile:${pe_build}\\winpe.wim /index:1 /MountDir:${pe_mount}",
    path    => $::path,
    require => [File['pe_build'],Exec['install_adk']],
  }
  exec { 'unmount_pe':
    command     => "cmd.exe /c dism.exe /Unmount-Wim /WimFile:${pe_build}\\winpe.wim /MountDir:${pe_mount} /discard",
    refreshonly => true,
    require     => [Exec['mount_pe'],Exec['install_adk']],
  }

  exec { 'commit_pe':
    command     => "cmd.exe /c dism.exe /Unmount-Wim /MountDir:${pe_mount} /commit",
    refreshonly => true,
    require     => [Exec['mount_pe'],Exec['create_bcd']],
  }
    file {"${pe_pxe}\\Boot\\pxeboot.com":
    ensure  => file,
    source  => "${pe_mount}\\Windows\\Boot\\PXE\\pxeboot.com",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [Exec['mount_pe'],File["${pe_pxe}\\Boot"]],
  }
    file {"${pe_pxe}\\Boot\\pxeboot.0":
    ensure  => file,
    source  => "${pe_mount}\\Windows\\Boot\\PXE\\pxeboot.n12",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [Exec['mount_pe'],File["${pe_pxe}\\Boot\\pxeboot.com"]],
  }
  file {"${pe_pxe}\\Boot\\bootmgr.exe":
    ensure  => file,
    source  => "${pe_mount}\\Windows\\Boot\\PXE\\bootmgr.exe",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [Exec['mount_pe'],File["${pe_pxe}\\Boot\\pxeboot.0"]],
  }
  file {"${pe_pxe}\\Boot\\abortpxe.com":
    ensure  => file,
    source  => "${pe_mount}\\Windows\\Boot\\PXE\\abortpxe.com",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [Exec['mount_pe'],File["${pe_pxe}\\Boot\\bootmgr.exe"]],
  }
  file {"${pe_pxe}\\Boot\\boot.sdi":
    ensure  => file,
    source  => "${pe_build}\\media\\Boot\\boot.sdi",
    mode    => '0770',
    owner   => 'Administrator',
    group   => 'Administrators',
    require => [Exec['mount_pe'],File["${pe_build}\\media","${pe_pxe}\\Boot\\abortpxe.com"]],
    before  => Exec['create_bcd'],
  }



  exec {'install_winpe_wmi':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_wmi}",
    require => Exec['mount_pe','install_adk'],
  }

  exec {'install_winpe_wmi_en-us':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_wmi_enus}",
    require => Exec['mount_pe','install_adk','install_winpe_wmi'],
  }

  exec {'install_winpe_hta':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_hta}",
    require => Exec['mount_pe','install_adk','install_winpe_wmi_en-us'],
  }

  exec {'install_winpe_hta_en-us':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_hta_enus}",
    require => Exec['mount_pe','install_adk','install_winpe_hta'],
  }

  exec {'install_winpe_scripting':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_scripting}",
    require => Exec['mount_pe','install_adk','install_winpe_hta_en-us'],
  }
  exec {'install_winpe_netfx4':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_netfx4}",
    require => Exec['mount_pe','install_adk','install_winpe_scripting'],
  }
  exec {'install_winpe_netfx4_en-us':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_netfx4_enus}",
    require => Exec['mount_pe','install_adk','install_winpe_netfx4'],
  }
  exec {'install_winpe_powershell3':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_powershell3}",
    require => Exec['mount_pe','install_adk','install_winpe_netfx4_en-us'],
  }
  exec {'install_winpe_powershell3_en-us':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_powershell3_enus}",
    require => Exec['mount_pe','install_adk','install_winpe_powershell3'],
  }
  exec {'install_winpe_storagewmi':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_storagewmi}",
    require => Exec['mount_pe','install_adk','install_winpe_powershell3_en-us'],
  }
  exec {'install_winpe_storagewmi_en-us':
    command => "dism.exe /image:${pe_mount} /Add-Package /PackagePath:${winpe_storagewmi_enus}",
    require => Exec['mount_pe','install_adk','install_winpe_storagewmi'],
  }

  class {'petools::dell_drivers':}
  class {'petools::kvm_drivers':}

  exec {'install_device_drivers':
    command => "dism.exe /image:${pe_mount} /Add-Driver /driver:${pe_drivers} /recurse /forceunsigned",
#    require => Exec['mount_pe','7z_extract_zip','7z_extract_iso','install_winpe_storagewmi_en-us'],
    require => [Exec['mount_pe','install_winpe_storagewmi_en-us'], Class['petools::dell_drivers','petools::kvm_drivers']]
  }
  file {"${pe_bin}\\bcdcreate.cmd":
    ensure  => file,
    source  => 'puppet:///modules/petools/edit_bcd_for_pxe.cmd',
    require => File['pe_bin'],
  }

  exec {'create_bcd':
    command => "cmd.exe /c ${pe_bin}\\bcdcreate.cmd",
    cwd     => "${pe_pxe}\\Boot",
    creates => "${pe_pxe}\\Boot\\BCD",
    require => [Exec['install_device_drivers'],File['pe_bin',"${pe_pxe}\\Boot\\boot.sdi"]],
    notify  => Exec['commit_pe'],
  }

  file { 'winpe_image_final':
    ensure  => file,
    path    => "${pe_pxe}\\Boot\\winpe.wim",
    source  => "${pe_build}\\winpe.wim",
    require => Exec['commit_pe'],
    notify  => Exec['copy_pe_pxe_to_q'],
  }
  #  exec {'copy_pe_pxe_to_q':
  #  command     => "cmd.exe /c xcopy.exe ${pe_pxe}\\Boot ${drive_letter}:\\",
  #  cwd         => 'q:\\',
  #  require     => [File['winpe_image_final'],Exec['mount_quartermaster']],
  #  refreshonly => true,
  #}
}
