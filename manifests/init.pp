# Class: petools
#
# This retrieves and Installs the ADK on a windows host
# It also creates an x86_64 winpe boot image
# and customizes it for use in an automated deployment infrastructure
#


class petools (

  $pe_dir              = 'c:\\winpe',
  $pe_programs         = 'c:\winpe\build\mount\Program Files (x86)',

  # Our WinPE Folder Structure
  $pe_src              = "${pe_dir}\\src",
  $pe_drivers          = "${pe_dir}\\src\\drivers",
  $pe_bin              = "${pe_dir}\\bin",
  $pe_logs             = "${pe_dir}\\logs",
  $pe_build            = "${pe_dir}\\build",
  $pe_mount            = "${pe_dir}\\build\\mount",
  #$pe_programs        = "${pe_mount}\\Program Files (x86)",
  $pe_iso              = "${pe_dir}\\ISO",
  $pe_pxe              = "${pe_dir}\\PXE",
  $pe_tmp              = "${pe_dir}\\tmp",

  # ADK Url and Install Options
#  $adk_url             = 'http://download.microsoft.com/download/9/9/F/99F5E440-5EB5-4952-9935-B99662C3DF70/adk/adksetup.exe',
  $adk_url             = 'https://go.microsoft.com/fwlink/p/?linkid=859206',

  $adk_file            = 'adksetup.exe',
  $adk_features        = 'OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment',
  $adk_install_log     = "${pe_logs}\\adksetup.log",

  # Windows PE Specific Paths
  $pe_root             = 'C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment',
  $pe_amd64_src        = 'C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64',
  $pe_x32_src          = 'C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\x86',
  $pe_package_src      = 'C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs',
  $pe_deployment_tools = 'C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Deployment Tools',
  $dism_path           = "${pe_deployment_tools}\\amd64\\DISM",
  $bcd_path            = "${pe_deployment_tools}\\amd64\\BCDBoot",
  $wism_path           = "${pe_deployment_tools}\\WSIM",

  # Windows PE Packages
  $winpe_wmi              = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\WinPE-WMI.cab"',
  $winpe_wmi_enus         = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\en-us\\WinPE-WMI_en-us.cab"',
  $winpe_hta              = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\WinPE-WMI.cab"',
  $winpe_hta_enus         = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\en-us\\WinPE-WMI_en-us.cab"',
  $winpe_scripting        = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\WinPE-Scripting.cab"',
#  $winpe_netfx4           = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\WinPE-NetFx4.cab"',
  $winpe_netfx4           = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\WinPE-NetFx.cab"',
#  $winpe_netfx4_enus      = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\en-us\\WinPE-NetFx4_en-us.cab"',
  $winpe_netfx4_enus      = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\en-us\\WinPE-NetFx_en-us.cab"',
  $winpe_powershell3      = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\WinPE-PowerShell.cab"',
  $winpe_powershell3_enus = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\en-us\\WinPE-PowerShell_en-us.cab"',
  $winpe_storagewmi       = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\WinPE-StorageWMI.cab"',
  $winpe_storagewmi_enus  = '"C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\WinPE_OCs\\en-us\\WinPE-StorageWMI_en-us.cab"',


  $winpath         = " C:\\windows\\${system32};c:\\winpe\\bin;${::path}",
  $powershell_path = 'c:\\Windows\\${system32}\\WindowsPowerShell\\v1.0',
  $zip7_exe_path   = 'c:\\Program\ Files\\7-Zip',
  $path            = "${winpath};${powershell_path};${::path}",

){




  Exec{
#    path => "$powershell_path;$winpath;$::path",
    path => "${::zip7_path};${::powershell_path};${::winpath}",
  }

include petools::adk
#
# dell_driver class can be used to extract zipfile of device drivers.
#
#include petools::dell_drivers
#include petools::kvm_drivers
# include petools::7zip
package{'7zip':
  ensure   => latest,
  provider => chocolatey,
}
include petools::quartermaster
#include petools::wsim

}
