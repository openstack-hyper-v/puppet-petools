Rem Creates BCD (boot configuration data) for 2 Windows PE 2.0 images
set BCD-File=c:\winpe\PXE\BCD
del %BCD-File%
Bcdedit /createstore %BCD-File%

Bcdedit /store %BCD-File% /create {ramdiskoptions} /d "Ramdisk Options"
Bcdedit /store %BCD-File% /set {ramdiskoptions} ramdisksdidevice  boot
Bcdedit /store %BCD-File% /set {ramdiskoptions} ramdisksdipath  \boot\boot.sdi

for /f "tokens=1-3" %%a in ('Bcdedit /store %BCD-File% /create /d "WinPE amd64" /application osloader') do set guid1=%%c
Bcdedit /store %BCD-File% /set %guid1% systemroot \Windows
Bcdedit /store %BCD-File% /set %guid1% detecthal Yes
Bcdedit /store %BCD-File% /set %guid1% WinPE Yes
Bcdedit /store %BCD-File% /set %guid1% osdevice ramdisk=[boot]\Boot\amd64.wim,{ramdiskoptions}
Bcdedit /store %BCD-File% /set %guid1% device ramdisk=[boot]\Boot\amd64.wim,{ramdiskoptions}

for /f "tokens=1-3" %%a in ('Bcdedit /store %BCD-File% /create /d "WinPE x86" /application osloader') do set guid2=%%c
Bcdedit /store %BCD-File% /set %guid2% systemroot \Windows
Bcdedit /store %BCD-File% /set %guid2% detecthal Yes
Bcdedit /store %BCD-File% /set %guid2% WinPE Yes
Bcdedit /store %BCD-File% /set %guid2% osdevice ramdisk=[boot]\Boot\i386.wim,{ramdiskoptions}
Bcdedit /store %BCD-File% /set %guid2% device ramdisk=[boot]\Boot\i386.wim,{ramdiskoptions}

Bcdedit /store %BCD-File% /create {bootmgr} /d "Windows BootManager" 
Bcdedit /store %BCD-File% /set {bootmgr} timeout 30
Bcdedit /store %BCD-File% /set {bootmgr} displayorder %guid1% %guid2%
Bcdedit /store %BCD-File% /enum all
