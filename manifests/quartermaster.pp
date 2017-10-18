# Class: petools::quartermaster
#
# This copies the winpe image and files needed to
# pxeboot to a share located on the quartermaster server
# quartermaster module is required to exist somewhere on the network


class petools::quartermaster (

    $drive_letter     = 'k',
    $quartermaster_ip = '172.16.123.129',
    $q_fqdn           = 'quartermaster.localdomain',
    $pe_tftpboot      = 'pe-pxeroot',
    $pe_wwwroot       = 'winpe',

    $puppeturl        = 'https://downloads.puppetlabs.com/windows/',
    $puppetmsi        = 'puppet-3.1.0.msi'

){
  Exec{
    path => "${petools::powershell_path};${petools::winpath};${::path}",
  }



  exec { 'mount_q':
    command => "net.exe use ${drive_letter}: \\\\${quartermaster_ip}\\pe-pxeroot /user:guest",
  }
  exec { 'unmount_q':
    command     => "net.exe use ${drive_letter}: /d",
    refreshonly => true,
  }


  exec {'copy_pe_pxe_to_q':
    command     => "cmd.exe /c xcopy.exe ${petools::adk::pe_pxe}\\Boot ${drive_letter}:\\Boot /E /Y",
    cwd         => "${drive_letter}:\\Boot",
    require     => [File['winpe_image_final','q_pe_bootdir'],Exec['mount_q']],
    refreshonly => true,
    notify      => Exec['unmount_q'],
  }

  file {"${drive_letter}:\\winpe.menu":
    ensure  => file,
    content => template('petools/pxemenu.erb'),
#    source  => "puppet:///modules/petools/pxemenu",
    require =>  Exec['mount_q'],
  }
  file {'q_pe_bootdir':
    ensure  => directory,
    path    => "${drive_letter}:\\Boot",
    require => Exec['mount_q'],
  }
  file { 'startnet.cmd':
    ensure  => file,
    path    => "${petools::pe_mount}//Windows//System32//startnet.cmd",
    content => template('petools/startnet.erb'),
    require => Exec['mount_pe'],
  }

#  commands::ps-get-msi-from-web{'get-puppet-agent':
#    url  => "${puppeturl}/${puppetmsi}",
#    file => $puppetmsi,
#  }

#  exec {'install-puppet-on-winpe':
#    command => "cmd.exe /c msiexec.exe /a ${puppetmsi} /passive /log c:\wpepuppet.log PUPPET_MASTER_SERVER=\"${q_fqdn}\" INSTALLDIR='${petools::adk::pe_mount}\\program",
#    cwd     => "c:/winpe/src",
#    require => [Commands::Ps-get-msi-from-web['get-puppet-agent'],Exec['mount_pe']],
#  }
#  package { $puppetmsi:
#    ensure          => installed,
#    source          => "${petools::adk::pe_src}\\${puppetmsi}",
#    install_options => [ '/passive',{'INSTALLDIR' => 'c:\winpe\build\mount\Program Files (x86)'}],
#    require         => Exec['get-puppet-agent','mount_pe'],
#  }
}
