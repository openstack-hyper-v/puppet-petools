#copy /Y c:\winterop\WinPE\amd64\WinPE_x86.wim c:\winterop\WinPE\ISO\amd64\sources\boot.wim
BASEDIR=%1

"C:\winterop\Windows AIK\Tools\amd64\oscdimg.exe" -n -bc:\winterop\WinPE\jenkins\amd64\etfsboot.com c:\winterop\WinPE\jenkins\amd64\ISO winPE-amd64-jenkins-swarm.iso


#copy /Y c:\winterop\WinPE\amd64\WinPE_x86.wim c:\winterop\WinPE\amd64\pe-i386-vmdp-debug\ISO\sources\boot.wim
#"C:\winterop\Windows AIK\Tools\amd64\oscdimg.exe" -n -bc:\winterop\WinPE\amd64\pe-i386-vmdp-debug\etfsboot.com c:\winterop\WinPE\amd64\pe-i386-vmdp-debug\ISO pe-i386-vmdp-#debug.iso