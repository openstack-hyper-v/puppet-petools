# Class: petools::dell_drivers
#
# This retrieves dell drivers
# The cab file is currently unused
# Currently using a zipfile provided sperately
# zipfile location should be provided in the site manifest
#


class petools::dell_drivers(

  $file       = 'Dell-WinPE-Drivers-A09.CAB',
  $url        = 'http://downloads.dell.com/folder00704623m/1/Dell-WinPE-Drivers-A09.CAB',
  $pe_bin     = $petools::adk::pe_bin,
  $pe_src     = $petools::adk::pe_src,
  $pe_drivers = $petools::adk::pe_drivers,

){
  exec {'get-dell-drivers-cab':
    path    => $::path,
    command => "c:\\Windows\\sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy remotesigned -Command Invoke-WebRequest -UseBasicParsing -uri ${url} -OutFile ${file}",
    creates => "${pe_src}\${file}",
    cwd     => $pe_src,
    require => File['pe_src']
  }

  file {'Drivers':
    path   => "${pe_drivers}\\Drivers.zip",
    source => 'puppet:///modules/petools/Drivers.zip',
    mode   => '0770',
    owner  => 'Administrator',
    group  => 'Administrators',
  }

  commands::extract_archive {'dell_drivers':
    archivefile => 'Drivers.zip',
    archivepath => $pe_drivers,
    require => File['Drivers'],
  }
  
#  exec {'7z_extract_zip':
#    command => "7z.exe x ${pe_drivers}\\Drivers.zip",
#    path    => "c:\\Program Files\\7-Zip;${::path}",
#    cwd     => $pe_src,
#    require => [Package['7z930-x64'],File['Drivers']],
#  }

#  exec {'install_dell_driver':
#    command => "dism.exe /image:${petools::adk::pe_mount} /Add-Package /PackagePath: ${pe_src}\\${file}",
#    path    => $::path,
#    require => [Exec['mount_pe'],Exec['install_adk']],
#  }


}
