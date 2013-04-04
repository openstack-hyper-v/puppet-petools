REM ### winperc
@echo on
set BASEDIR=%1
set ARCH=amd64
set TEMPL=ISO
set ISO_FILE=winpe-%ARCH%-jenkins-swarm.iso
set MY_JENKINs=http://10.191.166.38:8080
REM set MY_JENKINs=http://10.1.1.89:8080
set WAIK_LOCATION=c:\winterop\Windows^ AIK
set SOURCE=%WAIK_LOCATION%\Tools\PETools\%ARCH%\
set DEST=%BASEDIR%
REM set JAVA_INST=http://download.oracle.com/otn-pub/java/jdk/7u4-b22
set INST=c:\winterop\WinPE\src\
set JAVA_FILE=jre-7u4-windows-x64.exe
set SWARM_CLIENT_URL=http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/1.7
set SWARM_CLIENT=swarm-client-1.7-jar-with-dependencies.jar


echo "cleanup previous wim mounts"
dism /Cleanup-Wim

REM :MOUNT_WIM
echo "Mount Wim file for Advanced configuration" ;
dism /Mount-Wim /WimFile:%BASEDIR%\winpe.wim /index:1 /MountDir:%BASEDIR%\mount
 

REM :PKG_INSTALL
REM ### INSTALL Some PACKAGES###
echo "install some default packages"

if exist "%SOURCE%\WinPE_FPs\winpe-scripting.cab" dism /image:%BASEDIR%\mount /Add-Package /PackagePath:"%SOURCE%\WinPE_FPs\winpe-scripting.cab"
if exist "%SOURCE%\WinPE_FPs\winpe-hta.cab" dism /image:%BASEDIR%\mount /Add-Package /PackagePath:"%SOURCE%\WinPE_FPs\winpe-hta.cab"
if exist "%SOURCE%\WinPE_FPs\winpe-wmi.cab" dism /image:%BASEDIR%\mount /Add-Package /PackagePath:"%SOURCE%\WinPE_FPs\winpe-wmi.cab"
if exist "%SOURCE%\WinPE_FPs\en-us\winpe-wmi_en-us.cab" dism /image:%BASEDIR%\mount /Add-Package /PackagePath:"%SOURCE%\WinPE_FPs\en-us\winpe-wmi_en-us.cab"

dism /image:%BASEDIR%\mount /Add-Driver /driver:%INST%\Drivers\ /recurse /forceunsigned


REM :JENKINS_PREP
REM ### JENKINS Slave Installation ###
echo "create jenkins folders on winPE"
mkdir %BASEDIR%\mount\jenkins
mkdir %BASEDIR%\mount\jenkins\workspace
mkdir %BASEDIR%\mount\jenkins\bin
mkdir %BASEDIR%\mount\jenkins\userContent
mkdir %BASEDIR%\mount\jenkins\jre
cd %BASEDIR%\mount\jenkins\bin


REM ### Silent Java Install ###
REM ### INSTALL JAVA FROM LOCAL SOURCE ###
echo "Start Java Silent Install" ;
run %INST%\java\%JAVA_FILE% /s INSTALLDIR=%BASEDIR%\mount\jenkins\jre STATIC=1

pause

REM ### DOWNLOAD JENKINS SLAVE JAR
REM echo "Downloading Jenkins Slave"
REM cd %BASEDIR%\mount\jenkins\bin
REM wget -cv --directory-prefix=%BASEDIR%\mount\jenkins\bin %MY_JENKINS%/jnlpJars/slave.jar .

REM ### DOWNLOAD SWARM CLIENT
echo "DOwnloading Swarm Client" ;
wget -cv --directory-prefix=%BASEDIR%\mount\jenkins\bin %SWARM_CLIENT_URL%/%SWARM_CLIENT%
echo "configure swarm to start in startnet"
echo X:\jenkins\jre\bin\java.exe -jar X:\jenkins\bin\swarm-client-1.7-jar-with-dependencies.jar -description WINPE-JENKINS-SLAVE -fsroot X:\jenkins\workspace -labels winpe>>  %BASEDIR%\mount\windows\system32\startnet.cmd


REM ### finalize IMAGE
echo "finalize and commit changes to winpe"
dism /Unmount-Wim /MountDir:%BASEDIR%\mount /commit

REM ### Copy Unmounted wim to boot.wim ###
echo "Copy newly created wim to boot.wim"
copy %BASEDIR%\winpe.wim %BASEDIR%\ISO\sources\boot.wim /Y


REM ### Create ISO ###
echo "create iso location"
mkdir %BASEDIR%\%TEMPL%
echo "creating iso"
oscdimg.exe -n -b%BASEDIR%\etfsboot.com %BASEDIR%\%TEMPL% %BASEDIR%\%ISO_FILE%



REM :fail2
REM dism /Unmount-Wim /MountDir:%BASEDIR%\mount /discard
