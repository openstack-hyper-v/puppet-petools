REM ### winperc
@echo on
set BASEDIR=%1
set ARCH=amd64
set TEMPL=ISO
set ISO_FILE=winpe-%ARCH%-base.iso
set WAIK_LOCATION=c:\winterop\Windows^ AIK
set SOURCE=%WAIK_LOCATION%\Tools\PETools\%ARCH%\
set DEST=<% scope.lookupvar('pe_build') %>
set INST=<%= scope.lookupvar('pe_src') %>
set JAVA_FILE=jre-7u4-windows-x64.exe
set SWARM_CLIENT_URL=http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/1.7
set SWARM_CLIENT_DEP=swarm-client-1.7-jar-with-dependencies.jar
set SWARM_CLIENT=swarm-client-1.7.jar

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

timeout /T 300 /nobreak; 
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
echo "Downloading Jenkins Slave"
cd %BASEDIR%\mount\jenkins\bin
wget -cv --directory-prefix=%BASEDIR%\mount\jenkins\bin %MY_JENKINS%/jnlpJars/slave.jar .

REM ### DOWNLOAD SWARM CLIENT
echo "DOwnloading Swarm Client" ;
wget -cv --directory-prefix=%BASEDIR%\mount\jenkins\bin %SWARM_CLIENT_URL%/%SWARM_CLIENT%
REM wget -cv --directory-prefix=%BASEDIR%\mount\jenkins\bin %SWARM_CLIENT_URL%/%SWARM_CLIENT_DEP%
echo "configure swarm to start in startnet"
REM echo X:\jenkins\jre\bin\java.exe -jar X:\jenkins\bin\swarm-client-1.7-jar-with-dependencies.jar -description WINPE-JENKINS-SLAVE -fsroot X:\jenkins\workspace -labels winpe>>  %BASEDIR%\mount\windows\system32\startnet.cmd
echo X:\jenkins\jre\bin\java.exe -jar X:\jenkins\bin\swarm-client-1.7.jar -description WINPE-JENKINS-SLAVE -fsroot X:\jenkins\workspace -labels winpe>>  %BASEDIR%\mount\windows\system32\startnet.cmd


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
