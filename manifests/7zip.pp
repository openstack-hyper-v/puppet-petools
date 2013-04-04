# Class: petools::7zip
#
# This installs 7zip compression utilities on the host
# 7zip is used in other modules to decompress archives
#

class petools::7zip(

  $file    = '7z930-x64.msi',

  # $url     = 'http://downloads.sourceforge.net/sevenzip/7z930-x64.msi',
  $url     = 'http://dl.7-zip.org/7z930-x64.msi',
  $pe_bin  = $petools::adk::pe_bin,
  $pe_src  = $petools::adk::pe_src,

){

  $instsrc  = "${pe_src}\\${file}"

  exec {'get-7zip':
    path    => $::path,
    command => "c:\\Windows\\sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy remotesigned -Command Invoke-WebRequest -UseBasicParsing -uri ${url} -OutFile ${file}",
    creates => $instsrc,
    cwd     => $pe_src,
    require => File['pe_src'],
    before  => Package['7z930-x64'],
  }

  package { '7z930-x64':
    ensure   => installed,
    source   => $instsrc,
    provider => 'windows',
    require  => Exec['get-7zip']
  }

}
