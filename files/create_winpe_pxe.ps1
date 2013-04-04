$env:BASEDIR = %1
cmd /c copype amd64 $env:BASEDIR
  Remove-Item $env:BASEDIR\etfsboot.com
  Move-Item $env:BASEDIR\ISO\boot\boot.sdi $env:BASEDIR\boot.sdi
  Remove-Item $env:BASEDIR\ISO
  dism.exe --% /Mount-Wim /WimFile:$env:BASEDIR\winpe.wim /index:1 /MountDir:$env:BASEDIR\mount
  Copy-Item $env:BASEDIR\mount\Windows\Boot\PXE\pxeboot.n12 $env:BASEDIR\pxeboot.n12
  Copy-Item $env:BASEDIR\mount\Windows\Boot\PXE\bootmgr.exe $env:BASEDIR\bootmgr.exe
  Copy-Item $env:BASEDIR\mount\Windows\System32\bcdedit.exe $env:BASEDIR\bcdedit.exe
  dism.exe --% /Unmount-Wim /MountDir:$env:BASEDIR\mount /commit
  Remove-Item $env:BASEDIR\mount
  Remove-Item BCD
  dism.exe --% /Unmount-Wim /MountDir:%BASEDIR%\mount /commit
  bcdedit.exe --% -createstore BCD
  $env:BCDEDIT = bcdedit.exe --% -store BCD
  $env:BCDEDIT -create {ramdiskoptions} -d "Ramdisk options"
  $env:BCDEDIT -set {ramdiskoptions} ramdisksdidevice boot
  $env:BCDEDIT -set {ramdiskoptions} ramdisksdipath \Boot\boot.sdi
  for /f "tokens=3" %%a in ('$env:BCDEDIT -create -d "Windows PE" -application osloader') do set GUID=%%a
  $env:BCDEDIT -set %GUID% systemroot \Windows
  $env:BCDEDIT -set %GUID% detecthal Yes
  $env:BCDEDIT -set %GUID% winpe Yes
  $env:BCDEDIT -set %GUID% osdevice ramdisk=[boot]\Boot\winpe.wim,{ramdiskoptions}
  $env:BCDEDIT -set %GUID% device ramdisk=[boot]\Boot\winpe.wim,{ramdiskoptions}
  $env:BCDEDIT -create {bootmgr} -d "Windows Boot Manager"
  $env:BCDEDIT -set {bootmgr} timeout 30
  $env:BCDEDIT -set {bootmgr} displayorder %GUID%
  del /Q bcdedit.exe
