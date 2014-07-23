# Vagrant 1.6.3 <http://www.vagrantup.com/downloads.html>
# VirtualBox 4.3.14 <https://www.virtualbox.org/wiki/Downloads>

Vagrant.require_version '~> 1.6.3'

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.box_version = '~> 14.04'

  config.vm.provision :shell, inline: <<-'SHELL'
    set -e -x
    apt-get update --quiet --quiet
    apt-get install --assume-yes --quiet --quiet git libgmp-dev zlib1g-dev
    if ! which ghc
    then
      test -f ghc-7.8.3-x86_64-unknown-linux-deb7.tar.xz ||
        wget --quiet http://www.haskell.org/ghc/dist/7.8.3/ghc-7.8.3-x86_64-unknown-linux-deb7.tar.xz
      test -d ghc-7.8.3 ||
        tar --extract --file ghc-7.8.3-x86_64-unknown-linux-deb7.tar.xz
      cd ghc-7.8.3
      ./configure
      make install
      cd ..
    fi
  SHELL

  config.vm.provision :shell, inline: <<-'SHELL', privileged: false
    set -e -x
    echo 'PATH=".cabal-sandbox/bin:$HOME/.cabal/bin:$PATH"' > .bash_profile
    source .bash_profile
    if ! which cabal
    then
      test -f cabal-install-v1.20.0.3.tar.gz ||
        wget --quiet https://github.com/haskell/cabal/archive/cabal-install-v1.20.0.3.tar.gz
      test -d cabal-cabal-install-v1.20.0.3 ||
        tar --extract --file cabal-install-v1.20.0.3.tar.gz
      cd cabal-cabal-install-v1.20.0.3/cabal-install
      ./bootstrap.sh
      cd ../..
    fi
    cabal update
    cabal sandbox init
    for package in happy scan stylish-haskell
    do
      which $package ||
        cabal install $package
    done
  SHELL
end
