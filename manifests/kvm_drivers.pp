# Class: petools::kvm_drivers
#
# This retrieves the virtio drivers for windowsi
# and extracts them for inclusion in the winpe image
#

class petools::kvm_drivers {

  $driverfile = 'virtio-win-0.1-65.iso'
  $driverurl  = 'http://alt.fedoraproject.org/pub/alt/virtio-win/latest/images/bin/'
  $pe_bin     = $petools::adk::pe_bin
  $pe_src     = $petools::adk::pe_src
  $pe_drivers = $petools::adk::pe_drivers

  import 'commands'

  petools::commands::ps-get-drivers-from-web{'get-win-virtio':
    url  => "${driverurl}/${driverfile}",
    file => $driverfile,
  }

  petools::commands::extract_archive {'kvm_drivers':
    archivefile => $driverfile,
    archivepath => $pe_drivers,
    require => Exec['get-win-virtio'],
  }
  
#  exec {'7z_extract_iso':
#    command => "7z.exe x ${pe_drivers}\\${driverfile}",
#    path    => "c:\\Program Files\\7-Zip;${::path}",
#    cwd     => $pe_drivers,
#    require => [Package['7z930-x64'],Commands::Ps-get-drivers-from-web['get-win-virtio']],
#  }
}
