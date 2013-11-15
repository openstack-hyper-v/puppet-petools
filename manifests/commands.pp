# Class: petools::commands
# Reusable commands
#
class petools::commands {

# Define: petools::commands::ps-get-drivers-from-web
# this retrieves a driver file from a url using powershell
# placing it in the appropriate directory for inclusion in
# the winpe image

  define ps-get-drivers-from-web( $url, $file){
    exec { $name:
      path    => $::path,
      command => "powershell.exe -executionpolicy remotesigned -Command Invoke-WebRequest -UseBasicParsing -uri ${url} -OutFile ${file}",
      creates => "${petools::adk::pe_drivers}\\${file}",
      cwd     => $petools::adk::pe_drivers,
      require => File [ 'pe_drivers' ],
    }

  }

# Define: petools:;commands::ps-get-msi-from-web
# Also retrieves a file from a url, however this is an installable msi
# places it in the appropriate directory
#
  define ps-get-msi-from-web ( $url, $file) {
    exec { $name:
      path    => $::path,
      command => "powershell.exe -executionpolicy remotesigned -Command Invoke-WebRequest -UseBasicParsing -uri ${url} -OutFile ${file}",
      creates => "${petools::adk::pe_src}\\${file}",
      cwd     => $petools::adk::pe_src,
      require => File [ 'pe_src' ],
    }
  }

# Define: petools::commands::mountdrive
# mounts a windows share
#
  define mountdrive ( $drive_letter, $server, $share ){
    $drive_letter = $name
    exec { "mount-${name}":
      command => "net.exe use ${drive_letter} \\\\${server}\\${share} /persist:yes",
      creates => "${drive_letter}/",
    }
  }

# Define: petools::commands::unmountdrive
# unmounts a windows share
#
  define unmountdrive {
    $drive_letter = $name
    exec { "unmount-${name}":
      command     => "net.exe use ${drive_letter} /delete",
    }
  }
# Define: petools::commands::extract_archive
# uses 7zip to extract an archive

  define extract_archive ($archivefile, $archivepath = $petools::adk::pe_src){
    exec {"7z_extract_${name}":
      command => "7z.exe x c:\\winpe\\src\\${archivefile}",
      path    => "c:\\Program Files\\7-Zip;${::path}",
      cwd     => $archivepath,
      # require => [Package['7z930-x64'],Exec['get-kvm-drivers']],
      require => Package['7z930-x64'],
    }
  }
}
