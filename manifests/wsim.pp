class petools::wsim {
  $w2012_eval_url = 'http://care.dlservice.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO?lcid=1033&cprod=winsvr2012rtmisotn'
  $w8_eval = 'http://care.dlservice.microsoft.com/download/5/3/C/53C31ED0-886C-4F81-9A38-F58CE4CE71E8/9200.16384.WIN8_RTM.120725-1247_X64FRE_ENTERPRISE_EVAL_EN-US-HRM_CENA_X64FREE_EN-US_DV5.ISO?lcid=1033'
  $eval_iso = 'X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
  $hyperv_url='http://msdn.microsoft.com/subscriptions/json/GetDownloadRequest?brand=MSDN&locale=en-us&fileId=50558&activexDisabled=false&akamaiDL=true'
#  $hyperv_iso=

  Exec{
      path => "${petools::powershell_path};${petools::winpath};${petools::adk::dism_path};${petools::adk::bcd_path};${petools::adk::wsim_path};$::path",
  }

  exec {"get_w2012_eval":
      command => "powershell.exe -executionpolicy remotesigned -Command Invoke-WebRequest -UseBasicParsing -uri ${w2012_eval_url} -OutFile ${eval_iso}",
      creates => "${petools::adk::pe_src}\\${eval_iso}",
      cwd     => $petools::adk::pe_src,
      require => File["pe_src"]
  }
  exec {"get_hvserver":
      command => "powershell.exe -executionpolicy remotesigned -Command Invoke-WebRequest -UseBasicParsing -uri ${hyperv_url} -OutFile ${hyperv_iso}",
      creates => "${petools::adk::pe_src}\\${hyperv_iso}",
      cwd     => $petools::adk::pe_src,
      require => File["pe_src"]
  }



  exec { "mount_u":
      command => "net.exe use u: \\\\${petools::quartermaster::quartermaster_ip}\\unattend /user:guest",
  }


  exec { "unmount_u":
      command     => "net.exe use u: /d ",
      refreshonly => true,
  }


  file {"q_unattend":
      ensure  => file,
      path    => "u:\\hv-2012-compute.xml",
      content => template("petools/unattend.erb"),
      require => Exec["mount_u"],
  }


}
