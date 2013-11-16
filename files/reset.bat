net use q: /d
net use u: /d
"c:\Program Files (x86)\Windows Kits\8.0\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\dism.exe" /Unmount-Wim /MountDir:C:\winpe\build\mount /discard
@powershell rm -Recurse -Force c:\winpe
#"c:\Program Files (x86)\Puppet Labs\Puppet\bin\puppet.bat" agent --debug --trace --verbose --test --server=quartermaster.openstack.tld
