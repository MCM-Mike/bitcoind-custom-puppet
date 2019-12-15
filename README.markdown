Puppet module for bitcoind
========

## Description

This module will install bitcoind on remote agent nodes

## Usage

* Installation from source - edit file `/etc/puppetlabs/code/environments/production/manifests/site.pp` and add
```
 node default {
 include bitcoind
 class { 'bitcoind::source': }
 }
```
* Class parameters
```
    class { 'bitcoind':
        testnet     => false,
        rpcuser     => 'super_secret_username',
        rpcpassword => 'really_extra_secret_password',
        rpcport     => 18332,
    }
```
