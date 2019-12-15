# Puppet master & agent setup

## Pre-requirements check
1. Check that two nodes can ping each other
2. Check that both nodes have the same time (ntp)
3. Ideally, we should have the OS supported by puppet
4. All commands shown here are executed from root user env

## Installing packages
1. We have debian stretch (9), so we need this (on both nodes!):
``` 
wget https://apt.puppetlabs.com/puppet-release-stretch.deb
wget https://apt.puppet.com/puppet-tools-release-stretch.deb # This one is needed only on master server
dpkg -i ./pupp*deb
apt update
```
2. On master, run:
```
apt-get install -y puppetserver pdk
```
3. On nodes (agents), run:
```
apt-get install -y puppet-agent
```

## Post install (configuration) task
1. Add each other (master and nodes) to everyone's /etc/hosts config file:
```
ip_addr_of_master master puppet
ip_addr_of_node btcnode01
```
You can also re-check everything works by pinging master or btcnode01 etc.

2. On master, add this lines to config /etc/puppetlabs/puppet/puppet.conf :
```
dns_alt_names = puppet-master,master,puppet
[main]
certname = master 
server = master 
environment = production
runinterval = 15m
```
3. On master, generate certificates, start and enable it:
```
/opt/puppetlabs/bin/puppetserver ca setup
systemctl start puppetserver
systemctl enable puppetserver
```
4. On agent, add this lines to config /etc/puppetlabs/puppet/puppet.conf :
```
[main]
certname = btcnode01
server = master
environment = production
runinterval = 15m
```
5. On agent, send certificate to master:
```
/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
```
6. On master, check & sign the certificate:
```
/opt/puppetlabs/bin/puppetserver ca list
/opt/puppetlabs/bin/puppetserver ca sign --all
```
7. Finally, on agent, check that everything is okay:
```
/opt/puppetlabs/bin/puppet agent --test
```
This show show something like:
```
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Retrieving locales
Info: Caching catalog for btcnode01
Info: Applying configuration version '1576397498'
Notice: Applied catalog in 0.02 seconds
```
Here we know it's working.

Configuration completed, now let's go to module setup.

# Module setup
1. On the master server, install sxiii-bitcoind module from puppet forge:
```
puppet module install sxiii-bitcoind
```
2. On the master server, add the module so it will be used by agents.
This can be achieved in different ways. For example, edit this file:
`/etc/puppetlabs/code/environments/production/manifests/site.pp` 
and add the following code:
```
 node default {
 include bitcoind
 class { 'bitcoind::source': }
 }
```
3. Module bitcoind will be used now. If you're too lazy to wait, sync 
the agent right away by running (on the agent):
```
/opt/puppetlabs/bin/puppet agent -t
```
Now you have to wait as agent downloads and compiles the bitcoin source code.
Depending on your agent hardware, it might take quite long (e.g. 30 minutes or even more).

After building, daemon will automatically start.
Wait 10~20 minutes and check if blockchain folder grows with: 
`du -lh /opt/data/crypto/btc/data`.

# Path notes
* compile path is /opt/data/bitcoin-src
* data-path is /opt/data/crypto/btc/data
* bitcoin daemon & config files are located at /opt/data/crypto/btc/data/bin/
