####
#
# Installs bitcoind from source
#
class bitcoind::source
{
    include bitcoind::params
    notify{'Starting build of bitcoind.': }
    # sudo dd if=/dev/zero of=/swapfile bs=64M count=16 && sudo mkswap /swapfile && sudo swapon /swapfile
    $repository = 'git://github.com/bitcoin/bitcoin.git'
    $requires   = [
        'git',
        'build-essential',
        'libssl-dev',
	'libboost-system-dev',
	'libboost-filesystem-dev',
	'libboost-program-options-dev',
	'libboost-chrono-dev',
	'libboost-test-dev',
	'libboost-thread-dev',
	'libtool',
	'autotools-dev',
	'autoconf',
	'automake',
	'pkg-config',
	'libdb-dev',
	'libdb++-dev',
	'libevent-dev',
    ]
    $clone_path = '/opt/data/bitcoin-src'
    $install_path = '/opt/data/crypto/btc/data/bin/'
    package { $requires:
        ensure => present,
    }
    file { $clone_path:
        ensure => directory,
    }
    exec { 'git clone bitcoin':
        path      => '/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/opt/data/crypto/btc/data/bin/:/opt/data/bitcoin-src:/sbin:.',
        command   => "git clone ${repository} ${clone_path}",
        creates   => "${clone_path}/.git",
        logoutput => true
    }
    exec { 'make bitcoin':
        path      => '/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/opt/data/crypto/btc/data/bin/:/opt/data/bitcoin-src:/sbin:.',
        command   => "./autogen.sh && ./configure --without-gui --with-incompatible-bdb && make",
        creates   => "${clone_path}/src/bitcoind",
        cwd       => "${clone_path}",
        logoutput => true,
        timeout   => 0,
    }
    exec { 'copy binary':
        path      => '/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/opt/data/crypto/btc/data/bin/:/opt/data/bitcoin-src:/sbin:.',
        command   => "cp ${clone_path}/src/bitcoind ${install_path}",
        creates   => "${install_path}/bitcoind",
        logoutput => true
    }
}
