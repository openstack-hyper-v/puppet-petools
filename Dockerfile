FROM msopenstack/sentinel-windowsservercore
RUN puppet module install puppetlabs-stdlib && puppet module install puppetlabs-powershell && puppet module install puppet-windowsfeature
RUN cd "c:\ProgramData\PuppetLabs\puppet\etc\modules" && git clone https://github.com/openstack-hyper-v/puppet-petools petools
RUN puppet apply --debug --trace --verbose --modulepath=c:\ProgramData\PuppetLabs\puppet\etc\modules c:\ProgramData\PuppetLabs\puppet\etc\modules\petools\tests\init.pp
