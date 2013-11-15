# Class: petools
#
# This retrieves and Installs the ADK on a windows host
# It also creates an x86_64 winpe boot image
# and customizes it for use in an automated deployment infrastructure
#


class petools {
  $winpath         = " C:\\windows\\sysnative;c:\\winpe\\bin;${::path}"
  $powershell_path = 'c:\\Windows\\sysnative\\WindowsPowerShell\\v1.0'
  $path            = "${winpath};${powershell_path};${::path}"

  Exec{
#    path => "$powershell_path;$winpath;$::path",
    path => "${powershell_path};${winpath}",
  }

include petools::adk
#
# dell_driver class can be used to extract zipfile of device drivers.
#
#include petools::dell_drivers
include petools::kvm_drivers
include petools::7zip
include petools::quartermaster
#include petools::wsim

}

