@echo off
if '%1' == '' goto error
set MNT=%CD%\mount

REM Copy DEFAULT boot.wim
echo Copying the original wim to a working copy
copy /Y %CD%\src\orig_boot.wim c:\mnt\winpe-vmdp\WinPE_x86.wim

REM Mount default boot.wim RW
echo "Mounting PE Boot image"
imagex /mountrw %CD%\WinPE_x86.wim 1 %MNT%
if '%errorlevel%' == '0' goto xenbus
goto fail


REM Install VMDP Drivers into wim

REM Xenbus Installation
:xenbus
echo Installing xenbus
peimg /inf=%1\xenbus.inf %MNT%\Windows
if '%errorlevel%' == '0' goto xenblk
goto drvfail

REM Xenblk installation
:xenblk
echo Installing xenblk
peimg /inf=%1\xenblk.inf %MNT%\Windows
if '%errorlevel%' == '0' goto xennet
goto drvfail

REM Xennet Installation
:xennet
echo Installing xennet
peimg /inf=%1\xennet.inf %MNT%\Windows
if '%errorlevel%' == '0' goto registry
goto drvfail

REM mount registry and import into pe hive
:registry
echo Loading WinPE System registry
reg load HKLM\WinPE-System %MNT%\Windows\system32\config\SYSTEM

echo Importing VMDP changes into WinPE System Registry
reg import %CD%\src\VMDP-WinPE-System.reg

echo Unloading WinPE System Registry
reg unload HKLM\WinPE-System

echo Loading WinPE Software registry
reg load HKLM\WinPE-Software %MNT%\Windows\system32\config\SOFTWARE

echo Importing VMDP changes into WinPE Software Registry
reg import %CD%\src\VMDP-WinPE-Software.reg

echo Unloading WinPE Software Registry
reg unload HKLM\WinPE-Software
goto commit

REM Unmount and commit changes
:commit
imagex /unmount /commit %MNT%
goto makeiso

REM Make standard and debug ISO
:makeiso
echo Making WinPE ISO
copy /Y %CD%\WinPE_x86.wim %CD%\pe-i386-vmdp\ISO\sources\boot.wim
"C:\Program Files\Windows AIK\Tools\amd64\oscdimg.exe" -n -b%CD%\pe-i386-vmdp\etfsboot.com %CD%\pe-i386-vmdp\ISO pe-i386-vmdp.iso

echo Making WinPE Debug ISO
copy /Y %CD%\WinPE_x86.wim %CD%\pe-i386-vmdp-debug\ISO\sources\boot.wim
"C:\Program Files\Windows AIK\Tools\amd64\oscdimg.exe" -n -b%CD%\pe-i386-vmdp-debug\etfsboot.com %CD%\pe-i386-vmdp-debug\ISO pe-i386-vmdp-debug.iso
goto end


REM Error Reporting
REM ---------------

:error
echo Missing Arguement!
echo Usage mk-vmdp-pe path_to_vmdp_driver_arch
goto end

:fail
echo Wim Mount failed
goto end

:drvfail
echo Driver Installation failed
imagex /unmount %MNT%
goto end

:end
echo Done